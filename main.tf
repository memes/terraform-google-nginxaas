terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.1"
    }
  }
}

data "google_iam_workload_identity_pool" "pool" {
  for_each                  = coalesce(var.workload_identity_pool_id, "unspecified") == "unspecified" ? {} : { pool = var.workload_identity_pool_id }
  workload_identity_pool_id = reverse(split("/", each.value))[0]
  project                   = try(reverse(split("/", each.value))[4], var.project_id)
}

data "google_compute_subnetwork" "subnets" {
  for_each  = var.subnets
  self_link = each.key
}

module "region_detail" {
  source  = "memes/region-detail/google"
  version = "1.1.7"
  regions = distinct([for subnet in data.google_compute_subnetwork.subnets : subnet.region])
}

locals {
  # Many resources need to parse the value of subnets fields into different formats, do that once to make bug fixing
  # easier
  subnets = { for k, v in var.subnets : k => {
    id                 = data.google_compute_subnetwork.subnets[k].id
    region             = reverse(split("/", data.google_compute_subnetwork.subnets[k].region))[0]
    network            = data.google_compute_subnetwork.subnets[k].network
    abbreviation       = module.region_detail.results[reverse(split("/", data.google_compute_subnetwork.subnets[k].region))[0]].abbreviation
    service_attachment = coalesce(v.service_attachment, "unspecified") == "unspecified" ? null : v.service_attachment
    producer_projects  = coalesce(v.service_attachment, "unspecified") == "unspecified" ? [] : [reverse(split("/", v.service_attachment))[4]]
    port               = v.port
  } }
  service_account_ids = distinct(compact([for k, v in var.subnets : v.service_account_id]))
  # If there are no service account ids provided, use 'disabled' as the only identity which is an illegal value that
  # should never match a legitimate service account id. Additionally, the attribute used to enable access will be set
  # to disabled.
  workload_identity_provider_disabled = length(local.service_account_ids) == 0
  workload_identity_attribute_value   = length(local.service_account_ids) == 0 ? "disabled" : "enabled"
  workload_identity_subjects          = length(local.service_account_ids) == 0 ? ["disabled"] : local.service_account_ids
}

resource "google_compute_network_attachment" "nginxaas" {
  for_each              = local.subnets
  project               = var.project_id
  name                  = format("%s-%s", var.prefix, each.value.abbreviation)
  description           = var.description
  region                = each.value.region
  connection_preference = "ACCEPT_MANUAL"
  producer_accept_lists = each.value.producer_projects
  subnetworks = [
    each.value.id,
  ]
}

resource "google_compute_region_network_endpoint_group" "nginxaas" {
  for_each              = { for k, v in local.subnets : k => v if v.service_attachment != null }
  project               = var.project_id
  name                  = format("%s-%s", var.prefix, each.value.abbreviation)
  region                = each.value.region
  network               = each.value.network
  subnetwork            = each.value.id
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  description           = var.description
  psc_target_service    = each.value.service_attachment
  psc_data {
    producer_port = try(each.value.port, 80)
  }
}

resource "google_iam_workload_identity_pool_provider" "nginxaas" {
  for_each                           = data.google_iam_workload_identity_pool.pool
  project                            = each.value.project
  workload_identity_pool_provider_id = replace(format("%s-nginxaas", var.prefix), "/[^a-z0-9-]/", "-")
  workload_identity_pool_id          = reverse(split("/", each.value.id))[0]
  display_name                       = "F5 NGINXaaS for Google Cloud"
  description                        = var.description
  disabled                           = local.workload_identity_provider_disabled
  attribute_mapping = {
    "google.subject"     = "assertion.sub"
    "attribute.nginxaas" = format("'%s'", local.workload_identity_attribute_value)
  }
  # Only allow integration with the specified NGINXaaS service account ids
  attribute_condition = format("assertion.sub in %s", jsonencode(local.workload_identity_subjects))
  oidc {
    # TODO: @memes - the effect of an empty list is to impose a match against the
    # fully-qualified workload identity pool name. This should be sufficient but
    # review.
    allowed_audiences = []
    issuer_uri        = "https://accounts.google.com"
  }
}

resource "google_project_iam_member" "logging" {
  for_each = data.google_iam_workload_identity_pool.pool
  project  = var.project_id
  member   = format("principalSet://iam.googleapis.com/%s/attribute.nginxaas/enabled", each.value.name)
  role     = "roles/logging.logWriter"
}

resource "google_project_iam_member" "monitoring" {
  for_each = data.google_iam_workload_identity_pool.pool
  project  = var.project_id
  member   = format("principalSet://iam.googleapis.com/%s/attribute.nginxaas/enabled", each.value.name)
  role     = "roles/monitoring.metricWriter"
}
