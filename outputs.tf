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

output "network_endpoint_groups_by_region" {
  value       = { for neg in google_compute_region_network_endpoint_group.nginxaas : reverse(split("/", neg.region))[0] => neg.self_link... }
  description = <<-EOD
  A map of Compute Engine region names to NEG self-links.
  EOD
}

output "network_endpoint_groups_by_name" {
  value       = { for k, v in google_compute_region_network_endpoint_group.nginxaas : k => v.self_link }
  description = <<-EOD
  A map of NEG names to self-links.
  EOD
}
