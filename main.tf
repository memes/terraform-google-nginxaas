terraform {
  required_version = ">= 1.5"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.1"
    }
  }
}

# Verify the existing workload identity pool is valid, if provided.
data "google_iam_workload_identity_pool" "pool" {
  for_each                  = coalesce(try(var.workload_identity.pool_id, null), "unspecified") == "unspecified" ? {} : { id = var.workload_identity.pool_id }
  workload_identity_pool_id = reverse(split("/", each.value))[0]
  project                   = try(reverse(split("/", each.value))[4], var.project_id)
}

# Verify each attachment entry has a valid subnet.
data "google_compute_subnetwork" "subnets" {
  for_each  = var.attachments == null ? {} : var.attachments
  self_link = each.value.subnet
}

module "region_detail" {
  source  = "memes/region-detail/google"
  version = "1.1.7"
  regions = distinct([for subnet in data.google_compute_subnetwork.subnets : subnet.region])
}

locals {
  # Handle null values as empty sets
  service_accounts = var.service_accounts == null ? [] : var.service_accounts
  secrets          = var.secrets == null ? [] : var.secrets
  # Transform the attachments variable, handling optional values as needed.
  attachments = var.attachments == null ? {} : { for k, v in var.attachments : k => {
    subnet            = data.google_compute_subnetwork.subnets[k].id
    region            = reverse(split("/", data.google_compute_subnetwork.subnets[k].region))[0]
    producer_projects = coalesce(v.service_attachment, "unspecified") == "unspecified" ? [] : [can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", v.service_attachment)) ? v.service_attachment : reverse(split("/", v.service_attachment))[4]]
    description       = v.description
    }
  }
  # Each attachment can have multiple ports - expand out.
  endpoint_groups = { for key in var.attachments == null ? [] : flatten([for k, v in var.attachments : formatlist("%s:%d", k, try(length(v.ports), 0) == 0 ? [] : v.ports)]) : key => {
    subnet             = data.google_compute_subnetwork.subnets[split(":", key)[0]].id
    name               = replace(key, ":", "-")
    region             = reverse(split("/", data.google_compute_subnetwork.subnets[split(":", key)[0]].region))[0]
    service_attachment = var.attachments[split(":", key)[0]].service_attachment
    port               = split(":", key)[1]
    description        = var.attachments[split(":", key)[0]].description
    } if can(regex("^(?:https://www.googleapis.com/compute/v1/)?projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/regions/[a-z]{2,}-[a-z]{2,}[0-9]/serviceAttachments/[a-z][a-z0-9-]{0,62}[a-z0-9]$", var.attachments[split(":", key)[0]].service_attachment))
  }
  # If there are no service account ids provided, use 'disabled' as the only identity as that is an illegal value that
  # should never match a legitimate service account id. Additionally, the attribute used to enable access will be set
  # to disabled.
  workload_identity_provider_disabled = length(local.service_accounts) == 0
  workload_identity_attribute_value   = length(local.service_accounts) == 0 ? "disabled" : "enabled"
  workload_identity_subjects          = length(local.service_accounts) == 0 ? ["disabled"] : local.service_accounts
  iam_secrets = { for pair in setproduct(local.secrets, keys(data.google_iam_workload_identity_pool.pool)) : join("-", pair) => {
    secret_id = pair[0]
    pool_name = data.google_iam_workload_identity_pool.pool[pair[1]].name
  } }
}


resource "google_iam_workload_identity_pool_provider" "nginxaas" {
  for_each                           = data.google_iam_workload_identity_pool.pool
  project                            = each.value.project
  workload_identity_pool_provider_id = coalesce(var.workload_identity.name, "f5-nginxaas-for-google-cloud")
  workload_identity_pool_id          = reverse(split("/", each.value.id))[0]
  display_name                       = coalesce(var.workload_identity.display_name, "F5 NGINXaaS for Google Cloud")
  description                        = coalesce(var.workload_identity.description, "OIDC provider for F5 NGINXaaS for Google Cloud")
  disabled                           = local.workload_identity_provider_disabled
  attribute_mapping = {
    "google.subject"     = "assertion.sub"
    "attribute.nginxaas" = format("'%s'", local.workload_identity_attribute_value)
  }
  # Only allow integration with the specified NGINXaaS service account ids
  attribute_condition = format("assertion.sub in %s", jsonencode(local.workload_identity_subjects))
  oidc {
    # TODO(@memes): The effect of an empty list is to impose a match against the fully-qualified workload identity pool
    # name. This should be sufficient but review.
    allowed_audiences = []
    issuer_uri        = "https://accounts.google.com"
  }
}

# Allow matching identities to send logs to this project.
resource "google_project_iam_member" "logging" {
  for_each = data.google_iam_workload_identity_pool.pool
  project  = var.project_id
  member   = format("principalSet://iam.googleapis.com/%s/attribute.nginxaas/enabled", each.value.name)
  role     = "roles/logging.logWriter"
}

# Allow matching identities to send metrics to this project.
resource "google_project_iam_member" "monitoring" {
  for_each = data.google_iam_workload_identity_pool.pool
  project  = var.project_id
  member   = format("principalSet://iam.googleapis.com/%s/attribute.nginxaas/enabled", each.value.name)
  role     = "roles/monitoring.metricWriter"
}

# Allow matching identities to access secrets.
resource "google_secret_manager_secret_iam_member" "secret" {
  for_each  = local.iam_secrets
  secret_id = each.value.secret_id
  member    = format("principalSet://iam.googleapis.com/%s/attribute.nginxaas/enabled", each.value.pool_name)
  role      = "roles/secretmanager.secretAccessor"
}

# Create the network attachment to NGINXaaS.
resource "google_compute_network_attachment" "nginxaas" {
  for_each              = local.attachments
  project               = var.project_id
  name                  = each.key
  description           = each.value.description
  region                = each.value.region
  connection_preference = "ACCEPT_MANUAL"
  producer_accept_lists = each.value.producer_projects
  subnetworks = [
    each.value.subnet,
  ]
}

# Provision a Network Endpoint Group for each network attachment/port combination.
resource "google_compute_region_network_endpoint_group" "nginxaas" {
  for_each              = local.endpoint_groups
  project               = var.project_id
  name                  = each.value.name
  region                = each.value.region
  subnetwork            = each.value.subnet
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  description           = each.value.description
  psc_target_service    = each.value.service_attachment
  psc_data {
    producer_port = each.value.port
  }
}
