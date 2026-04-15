output "network_attachments" {
  value       = { for attachment in google_compute_network_attachment.nginxaas : reverse(split("/", attachment.region))[0] => attachment.id }
  description = <<-EOD
  A map of region name to network attachment id.
  EOD
}

output "workload_identity_pool_provider_id" {
  value       = one([for pool in google_iam_workload_identity_pool_provider.nginxaas : pool.id])
  description = <<-EOD
  The id for the Workload Identity pool provider to use with F5 NGINXaas for Google Cloud.
  EOD
}

output "negs" {
  value       = { for neg in google_compute_region_network_endpoint_group.nginxaas : reverse(split("/", neg.region))[0] => neg.id }
  description = <<-EOD
  A map of region name to NEG id.
  EOD
}
