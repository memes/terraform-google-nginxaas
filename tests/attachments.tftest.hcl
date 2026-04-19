# Verify behavior with different values for attachments variable.

mock_provider "google" {
  mock_data "google_compute_subnetwork" {
    defaults = {
      region = "us-central1"
      id     = "projects/mock-project/regions/us-central1/subnetworks/mock-nginxaas"
    }
  }
}

variables {
  project_id = "mock-project"
}

run "empty" {
  variables {
    attachments = {}
  }
  assert {
    condition     = length(google_iam_workload_identity_pool_provider.nginxaas) == 0
    error_message = "Expected the count of Workload Identity Pool Provider to be 0"
  }
  assert {
    condition     = length(google_project_iam_member.logging) == 0
    error_message = "Expected the count of logWriter role binding to be 0"
  }
  assert {
    condition     = length(google_project_iam_member.monitoring) == 0
    error_message = "Expected the count of metricWriter role binding to be 0"
  }
  assert {
    condition     = length(google_secret_manager_secret_iam_member.secret) == 0
    error_message = "Expected the count of secretAccessor role binding to be 0"
  }
  assert {
    condition     = length(google_compute_network_attachment.nginxaas) == 0
    error_message = "Expected the count of Network Attachments to be 0"
  }
  assert {
    condition     = length(google_compute_region_network_endpoint_group.nginxaas) == 0
    error_message = "Expected the count of NEGs to be 0"
  }
}

run "one_region_no_service_attachments_no_ports" {
  variables {
    attachments = {
      "mock-1" = {
        subnet = "projects/mock-project/regions/us-central1/subnetworks/mock-nginxaas"
      }
    }
  }
  assert {
    condition     = length(google_iam_workload_identity_pool_provider.nginxaas) == 0
    error_message = "Expected the count of Workload Identity Pool Provider to be 0"
  }
  assert {
    condition     = length(google_project_iam_member.logging) == 0
    error_message = "Expected the count of logWriter role binding to be 0"
  }
  assert {
    condition     = length(google_project_iam_member.monitoring) == 0
    error_message = "Expected the count of metricWriter role binding to be 0"
  }
  assert {
    condition     = length(google_secret_manager_secret_iam_member.secret) == 0
    error_message = "Expected the count of secretAccessor role binding to be 0"
  }
  assert {
    condition     = length(google_compute_network_attachment.nginxaas) == 1
    error_message = "Expected the count of Network Attachments to be 1"
  }
  assert {
    condition     = alltrue([for a in google_compute_network_attachment.nginxaas : a.project == "mock-project"])
    error_message = "Expected all network attachments to have a project of mock-project"
  }
  assert {
    condition     = alltrue([for a in google_compute_network_attachment.nginxaas : contains(["mock-1"], a.name)])
    error_message = "Expected all network attachments to have an expected name"
  }
  assert {
    condition     = length(distinct([for a in google_compute_network_attachment.nginxaas : a.name])) == length(google_compute_network_attachment.nginxaas)
    error_message = "Expected all network attachments to have a unique name"
  }
  assert {
    condition     = alltrue([for a in google_compute_network_attachment.nginxaas : a.description == null])
    error_message = "Expected all network attachments to have a null description"
  }
  assert {
    condition     = alltrue([for a in google_compute_network_attachment.nginxaas : contains(["us-central1"], a.region)])
    error_message = "Expected all network attachments to have an expected region"
  }
  assert {
    condition     = length(google_compute_region_network_endpoint_group.nginxaas) == 0
    error_message = "Expected the count of NEGs to be 0"
  }
}

run "single_region_single_service_attachments_no_ports" {
  variables {
    attachments = {
      "mock-1" = {
        subnet             = "projects/mock-project/regions/us-central1/subnetworks/mock-nginxaas"
        service_attachment = "projects/mock-project/regions/us-central1/serviceAttachments/mock-nginxaas"
      }
    }
  }
  assert {
    condition     = length(google_iam_workload_identity_pool_provider.nginxaas) == 0
    error_message = "Expected the count of Workload Identity Pool Provider to be 0"
  }
  assert {
    condition     = length(google_project_iam_member.logging) == 0
    error_message = "Expected the count of logWriter role binding to be 0"
  }
  assert {
    condition     = length(google_project_iam_member.monitoring) == 0
    error_message = "Expected the count of metricWriter role binding to be 0"
  }
  assert {
    condition     = length(google_secret_manager_secret_iam_member.secret) == 0
    error_message = "Expected the count of secretAccessor role binding to be 0"
  }
  assert {
    condition     = length(google_compute_network_attachment.nginxaas) == 1
    error_message = "Expected the count of Network Attachments to be 1"
  }
  assert {
    condition     = alltrue([for a in google_compute_network_attachment.nginxaas : a.project == "mock-project"])
    error_message = "Expected all network attachments to have a project of mock-project"
  }
  assert {
    condition     = alltrue([for a in google_compute_network_attachment.nginxaas : contains(["mock-1"], a.name)])
    error_message = "Expected all network attachments to have an expected name"
  }
  assert {
    condition     = length(distinct([for a in google_compute_network_attachment.nginxaas : a.name])) == length(google_compute_network_attachment.nginxaas)
    error_message = "Expected all network attachments to have a unique name"
  }
  assert {
    condition     = alltrue([for a in google_compute_network_attachment.nginxaas : a.description == null])
    error_message = "Expected all network attachments to have a null description"
  }
  assert {
    condition     = alltrue([for a in google_compute_network_attachment.nginxaas : contains(["us-central1"], a.region)])
    error_message = "Expected all network attachments to have an expected region"
  }
  assert {
    condition     = length(google_compute_region_network_endpoint_group.nginxaas) == 0
    error_message = "Expected the count of NEGs to be 0"
  }
}

run "single_region_single_service_attachments_one_port" {
  variables {
    attachments = {
      "mock-1" = {
        subnet             = "projects/mock-project/regions/us-central1/subnetworks/mock-nginxaas"
        service_attachment = "projects/mock-project/regions/us-central1/serviceAttachments/mock-nginxaas"
        ports              = [443]
      }
    }
  }
  assert {
    condition     = length(google_iam_workload_identity_pool_provider.nginxaas) == 0
    error_message = "Expected the count of Workload Identity Pool Provider to be 0"
  }
  assert {
    condition     = length(google_project_iam_member.logging) == 0
    error_message = "Expected the count of logWriter role binding to be 0"
  }
  assert {
    condition     = length(google_project_iam_member.monitoring) == 0
    error_message = "Expected the count of metricWriter role binding to be 0"
  }
  assert {
    condition     = length(google_secret_manager_secret_iam_member.secret) == 0
    error_message = "Expected the count of secretAccessor role binding to be 0"
  }
  assert {
    condition     = length(google_compute_network_attachment.nginxaas) == 1
    error_message = "Expected the count of Network Attachments to be 1"
  }
  assert {
    condition     = alltrue([for a in google_compute_network_attachment.nginxaas : a.project == "mock-project"])
    error_message = "Expected all network attachments to have a project of mock-project"
  }
  assert {
    condition     = alltrue([for a in google_compute_network_attachment.nginxaas : contains(["mock-1"], a.name)])
    error_message = "Expected all network attachments to have an expected name"
  }
  assert {
    condition     = length(distinct([for a in google_compute_network_attachment.nginxaas : a.name])) == length(google_compute_network_attachment.nginxaas)
    error_message = "Expected all network attachments to have a unique name"
  }
  assert {
    condition     = alltrue([for a in google_compute_network_attachment.nginxaas : a.description == null])
    error_message = "Expected all network attachments to have a null description"
  }
  assert {
    condition     = alltrue([for a in google_compute_network_attachment.nginxaas : contains(["us-central1"], a.region)])
    error_message = "Expected all network attachments to have an expected region"
  }
  assert {
    condition     = length(google_compute_region_network_endpoint_group.nginxaas) == 1
    error_message = "Expected the count of NEGs to be 1"
  }
  assert {
    condition     = alltrue([for n in google_compute_region_network_endpoint_group.nginxaas : n.project == "mock-project"])
    error_message = "Expected all NEGs to have a project of mock-project"
  }
  assert {
    condition     = alltrue([for n in google_compute_region_network_endpoint_group.nginxaas : contains(["mock-1-443"], n.name)])
    error_message = "Expected all NEGs to have an expected name"
  }
  assert {
    condition     = length(distinct([for n in google_compute_region_network_endpoint_group.nginxaas : n.name])) == length(google_compute_region_network_endpoint_group.nginxaas)
    error_message = "Expected all NEGs to have a unique name"
  }
  assert {
    condition     = alltrue([for n in google_compute_region_network_endpoint_group.nginxaas : contains(["us-central1"], n.region)])
    error_message = "Expected all NEGs to have an expected region"
  }
  assert {
    condition     = alltrue([for n in google_compute_region_network_endpoint_group.nginxaas : contains(["projects/mock-project/regions/us-central1/subnetworks/mock-nginxaas"], n.subnetwork)])
    error_message = "Expected all NEGs to have an expected subnetwork"
  }
  assert {
    condition     = alltrue([for n in google_compute_region_network_endpoint_group.nginxaas : n.network_endpoint_type == "PRIVATE_SERVICE_CONNECT"])
    error_message = "Expected all NEGs to have an expected network endpoint type"
  }
  assert {
    condition     = alltrue([for n in google_compute_region_network_endpoint_group.nginxaas : n.description == null])
    error_message = "Expected all NEGs to have a null description"
  }
  assert {
    condition     = alltrue([for n in google_compute_region_network_endpoint_group.nginxaas : contains(["projects/mock-project/regions/us-central1/serviceAttachments/mock-nginxaas"], n.psc_target_service)])
    error_message = "Expected all NEGs to have an expected psc_target_service"
  }
  assert {
    condition     = alltrue([for n in google_compute_region_network_endpoint_group.nginxaas : contains(["443"], n.psc_data[0].producer_port)])
    error_message = "Expected all NEGs to have an expected producer port"
  }
  assert {
    condition     = length(distinct([for n in google_compute_region_network_endpoint_group.nginxaas : n.psc_data[0].producer_port])) == length(google_compute_region_network_endpoint_group.nginxaas)
    error_message = "Expected all NEGs to have a unique producer port"
  }
}

run "single_region_single_service_attachments_three_ports" {
  variables {
    attachments = {
      "mock-1" = {
        subnet             = "projects/mock-project/regions/us-central1/subnetworks/mock-nginxaas"
        service_attachment = "projects/mock-project/regions/us-central1/serviceAttachments/mock-nginxaas"
        ports              = [10, 20, 30]
      }
    }
  }
  assert {
    condition     = length(google_iam_workload_identity_pool_provider.nginxaas) == 0
    error_message = "Expected the count of Workload Identity Pool Provider to be 0"
  }
  assert {
    condition     = length(google_project_iam_member.logging) == 0
    error_message = "Expected the count of logWriter role binding to be 0"
  }
  assert {
    condition     = length(google_project_iam_member.monitoring) == 0
    error_message = "Expected the count of metricWriter role binding to be 0"
  }
  assert {
    condition     = length(google_secret_manager_secret_iam_member.secret) == 0
    error_message = "Expected the count of secretAccessor role binding to be 0"
  }
  assert {
    condition     = length(google_compute_network_attachment.nginxaas) == 1
    error_message = "Expected the count of Network Attachments to be 1"
  }
  assert {
    condition     = alltrue([for a in google_compute_network_attachment.nginxaas : a.project == "mock-project"])
    error_message = "Expected all network attachments to have a project of mock-project"
  }
  assert {
    condition     = alltrue([for a in google_compute_network_attachment.nginxaas : contains(["mock-1"], a.name)])
    error_message = "Expected all network attachments to have an expected name"
  }
  assert {
    condition     = length(distinct([for a in google_compute_network_attachment.nginxaas : a.name])) == length(google_compute_network_attachment.nginxaas)
    error_message = "Expected all network attachments to have a unique name"
  }
  assert {
    condition     = alltrue([for a in google_compute_network_attachment.nginxaas : a.description == null])
    error_message = "Expected all network attachments to have a null description"
  }
  assert {
    condition     = alltrue([for a in google_compute_network_attachment.nginxaas : contains(["us-central1"], a.region)])
    error_message = "Expected all network attachments to have an expected region"
  }
  assert {
    condition     = length(google_compute_region_network_endpoint_group.nginxaas) == 3
    error_message = "Expected the count of NEGs to be 3"
  }
  assert {
    condition     = alltrue([for n in google_compute_region_network_endpoint_group.nginxaas : n.project == "mock-project"])
    error_message = "Expected all NEGs to have a project of mock-project"
  }
  assert {
    condition     = alltrue([for n in google_compute_region_network_endpoint_group.nginxaas : contains(["mock-1-10", "mock-1-20", "mock-1-30"], n.name)])
    error_message = "Expected all NEGs to have an expected name"
  }
  assert {
    condition     = length(distinct([for n in google_compute_region_network_endpoint_group.nginxaas : n.name])) == length(google_compute_region_network_endpoint_group.nginxaas)
    error_message = "Expected all NEGs to have a unique name"
  }
  assert {
    condition     = alltrue([for n in google_compute_region_network_endpoint_group.nginxaas : contains(["us-central1"], n.region)])
    error_message = "Expected all NEGs to have an expected region"
  }
  assert {
    condition     = alltrue([for n in google_compute_region_network_endpoint_group.nginxaas : contains(["projects/mock-project/regions/us-central1/subnetworks/mock-nginxaas"], n.subnetwork)])
    error_message = "Expected all NEGs to have an expected subnetwork"
  }
  assert {
    condition     = alltrue([for n in google_compute_region_network_endpoint_group.nginxaas : n.network_endpoint_type == "PRIVATE_SERVICE_CONNECT"])
    error_message = "Expected all NEGs to have an expected network endpoint type"
  }
  assert {
    condition     = alltrue([for n in google_compute_region_network_endpoint_group.nginxaas : n.description == null])
    error_message = "Expected all NEGs to have a null description"
  }
  assert {
    condition     = alltrue([for n in google_compute_region_network_endpoint_group.nginxaas : contains(["projects/mock-project/regions/us-central1/serviceAttachments/mock-nginxaas"], n.psc_target_service)])
    error_message = "Expected all NEGs to have an expected psc_target_service"
  }
  assert {
    condition     = alltrue([for n in google_compute_region_network_endpoint_group.nginxaas : contains(["10", "20", "30"], n.psc_data[0].producer_port)])
    error_message = "Expected all NEGs to have an expected producer port"
  }
  assert {
    condition     = length(distinct([for n in google_compute_region_network_endpoint_group.nginxaas : n.psc_data[0].producer_port])) == length(google_compute_region_network_endpoint_group.nginxaas)
    error_message = "Expected all NEGs to have a unique producer port"
  }
}
