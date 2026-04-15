variable "project_id" {
  type     = string
  nullable = false
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "The project_id value must be a valid Google Cloud project identifier"
  }
  description = <<-EOD
  The Google Cloud project where the resources will be created.
  EOD
}

variable "subnets" {
  type = map(object({
    service_attachment = optional(string)
    port               = optional(number, 80)
    service_account_id = optional(string)
  }))
  nullable = false
  validation {
    condition     = length(var.subnets) > 0 && alltrue([for k, v in var.subnets : can(regex("^(?:https://www.googleapis.com/compute/v1/)?projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/regions/[a-z]{2,}-[a-z]{2,}[0-9]/subnetworks/[a-z]([a-z0-9-]+[a-z0-9])?$", k)) && (v == null ? true : (coalesce(v.service_attachment, "unspecified") == "unspecified" ? true : can(regex("^(?:https://www.googleapis.com/compute/v1/)?projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/regions/[a-z]{2,}-[a-z]{2,}[0-9]/serviceAttachments/[a-z][a-z0-9-]{0,62}[a-z0-9]$", v.service_attachment))) && (v.port == null ? true : floor(v.port) == v.port && v.port > 0 && v.port < 65536) && (v.service_account_id == null ? true : can(regex("^[1-9][0-9]+$", v.service_account_id))))])
    error_message = "Each subnet key must be a valid subnetwork self-link URI, and the value must be empty or contain a valid service attachment self-link and port."
  }
  description = <<-EOD
  A map of Compute Engine subnetwork self-links to F5 NGINXaaS for Google Cloud service attachment self-links.
  EOD
}

variable "prefix" {
  type     = string
  nullable = false
  default  = "nginxaas"
  validation {
    # Most resource names can be up to 63 chars, but since the code will append -nginxaas when creating a WIF provider,
    # limit the prefix to 54 chars.
    condition     = can(regex("^[a-z][a-z0-9-]{0,53}$", var.prefix))
    error_message = "The prefix variable must be RFC1035 compliant and between 1 and 54 characters in length."
  }
  description = <<-EOD
  The prefix to use when naming resources; must be between 1 and 54 characters in length and RFC1035 compliant.
  EOD
}

variable "description" {
  type        = string
  nullable    = true
  default     = "F5 NGINXaaS for Google Cloud"
  description = <<-EOD
    An optional description to assign to each network attachment.
    EOD
}

variable "workload_identity_pool_id" {
  type     = string
  nullable = true
  default  = null
  validation {
    condition     = coalesce(var.workload_identity_pool_id, "unspecified") == "unspecified" ? true : can(regex("^projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/locations/global/workloadIdentityPools/[a-z0-9-]{4,32}$", var.workload_identity_pool_id))
    error_message = "The workload_identity_pool_id must be empty or a valid Workload Identity name or id."
  }
  description = <<-EOD
    An optional identifier of an *existing* Workload Identity pool to which a new provider for NGINXaaS will be created.
    EOD
}
