output "network_attachments" {
  value       = { for attachment in google_compute_network_attachment.nginxaas : reverse(split("/", attachment.region))[0] => attachment.id... }
  description = <<-EOD
  A map of Compute Engine region names to network attachment identifiers.
  EOD
}

output "workload_identity_pool_provider_id" {
  value       = one([for pool in google_iam_workload_identity_pool_provider.nginxaas : pool.id])
  description = <<-EOD
  The identifier of the Workload Identity pool provider to use with F5 NGINXaas for Google Cloud, if created.
  EOD
}

output "network_endpoint_groups" {
  value       = { for neg in google_compute_region_network_endpoint_group.nginxaas : reverse(split("/", neg.region))[0] => neg.id... }
  description = <<-EOD
  A map of Compute Engine region names to NEG identifiers.
  EOD
}
