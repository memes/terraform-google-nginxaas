# terraform-google-nginxaas

![GitHub release](https://img.shields.io/github/v/release/memes/terraform-google-nginxaas?sort=semver)
![GitHub last commit](https://img.shields.io/github/last-commit/memes/terraform-google-nginxaas)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-3.0-4baaaa.svg)](CODE_OF_CONDUCT.md)

<!-- markdownlint-disable MD033 MD034 MD060 -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 7.1 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_region_detail"></a> [region\_detail](#module\_region\_detail) | memes/region-detail/google | 1.1.7 |

## Resources

| Name | Type |
| ---- | ---- |
| [google_compute_network_attachment.nginxaas](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_attachment) | resource |
| [google_compute_region_network_endpoint_group.nginxaas](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_endpoint_group) | resource |
| [google_iam_workload_identity_pool_provider.nginxaas](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_project_iam_member.logging](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.monitoring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_secret_manager_secret_iam_member.secret](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_compute_subnetwork.subnets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |
| [google_iam_workload_identity_pool.pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_workload_identity_pool) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Google Cloud project where the resources will be created. | `string` | n/a | yes |
| <a name="input_attachments"></a> [attachments](#input\_attachments) | A map of named attachments to be created and linked with F5 NGINXaaS for Google Cloud. The module is designed to<br/>support partial provisioning, where only some values are known during each pass. | <pre>map(object({<br/>    subnet             = string<br/>    description        = optional(string)<br/>    service_attachment = optional(string)<br/>    port               = optional(number, 443)<br/>  }))</pre> | `null` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | A set of Secret Manager secret identities that will be granted read-only access to principals which are entitled<br/>through the NGINXaaS OIDC provider. | `set(string)` | `null` | no |
| <a name="input_service_accounts"></a> [service\_accounts](#input\_service\_accounts) | An optional set of service account identifiers, as provided by F5 NGINXaaS for Google Cloud. These accounts will be<br/>permitted to authenticated through an OIDC provider and granted access to send logs and metrics to the host project.<br/>The accounts will also be granted read-only access to Secret Manager secrets as set in `secrets` variable. | `set(string)` | `null` | no |
| <a name="input_workload_identity"></a> [workload\_identity](#input\_workload\_identity) | An optional identifier of an *existing* Workload Identity pool to which a new provider for NGINXaaS will be created.<br/>The optional name, display\_name, and description values can be used to override the default values. | <pre>object({<br/>    pool_id      = string<br/>    name         = optional(string, "f5-nginxaas-for-google-cloud")<br/>    display_name = optional(string, "F5 NGINXaaS for Google Cloud")<br/>    description  = optional(string, "OIDC provider for F5 NGINXaaS for Google Cloud")<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_negs"></a> [negs](#output\_negs) | A map of region name to NEG id. |
| <a name="output_network_attachments"></a> [network\_attachments](#output\_network\_attachments) | A map of region name to network attachment id. |
| <a name="output_workload_identity_pool_provider_id"></a> [workload\_identity\_pool\_provider\_id](#output\_workload\_identity\_pool\_provider\_id) | The id for the Workload Identity pool provider to use with F5 NGINXaas for Google Cloud. |
<!-- END_TF_DOCS -->
<!-- markdownlint-enable MD033 MD034 MD060 -->
