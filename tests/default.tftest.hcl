# Verify the module doesn't raise an error or create any resources when all optional values are missing.
mock_provider "google" {}

variables {
  project_id = "mock-project"
}

run "default" {
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
  assert {
    condition     = try(length(output.network_attachments), 0) == 0
    error_message = "Expected network_attachments output to be null or empty."
  }
  assert {
    condition     = output.workload_identity_pool_provider_name == null
    error_message = "Expected workload_identity_pool_provider_name output to be null."
  }
  assert {
    condition     = try(length(output.network_endpoint_groups_by_region), 0) == 0
    error_message = "Expected network_endpoint_groups_by_region output to be null or empty."
  }
  assert {
    condition     = try(length(output.network_endpoint_groups_by_name), 0) == 0
    error_message = "Expected network_endpoint_groups_by_name output to be null or empty."
  }
}
