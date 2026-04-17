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

variable "attachments" {
  type = map(object({
    subnet             = string
    description        = optional(string)
    service_attachment = optional(string)
    ports              = optional(set(number), [443])
  }))
  nullable = true
  validation {
    condition = try(length(var.attachments), 0) == 0 ? true : alltrue([
      for k, v in var.attachments :
      can(regex("^[a-z][a-z0-9-]{0,62}$", k)) &&
      can(regex("^(?:https://www.googleapis.com/compute/v1/)?projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/regions/[a-z]{2,}-[a-z]{2,}[0-9]/subnetworks/[a-z]([a-z0-9-]+[a-z0-9])?$", v.subnet)) &&
      (
        (coalesce(v.service_attachment, "unspecified") == "unspecified" ? true :
          can(regex("^(?:https://www.googleapis.com/compute/v1/)?projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/regions/[a-z]{2,}-[a-z]{2,}[0-9]/serviceAttachments/[a-z][a-z0-9-]{0,62}[a-z0-9]$", v.service_attachment)) ||
          can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", v.service_attachment))
        ) &&
        (v.ports == null ? true : alltrue([for port in v.ports : floor(port) == port && port > 0 && port < 65536]))
      )
    ])
    error_message = "Each attachments key must be a valid name, and the value must contain a valid subnet self-link, and may contain a valid service attachment self-link (or project) and port."
  }
  default     = null
  description = <<-EOD
  A map of named attachments to be created and linked with F5 NGINXaaS for Google Cloud. The module is designed to
  support partial provisioning, where only some values are known during each pass.
  EOD
}

variable "workload_identity" {
  type = object({
    pool_id      = string
    name         = optional(string, "f5-nginxaas-for-google-cloud")
    display_name = optional(string, "F5 NGINXaaS for Google Cloud")
    description  = optional(string, "OIDC provider for F5 NGINXaaS for Google Cloud")
  })
  nullable = true
  default  = null
  validation {
    condition = var.workload_identity == null ? true : (
      can(regex("^projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/locations/global/workloadIdentityPools/[a-z0-9-]{4,32}$", var.workload_identity.pool_id)) &&
      coalesce(var.workload_identity.name, "unspecified") == "unspecified" ? true : can(regex("^[a-z0-9-]{4,32}$", var.workload_identity.name)) &&
      try(length(var.workload_identity.display_name), 0) <= 32 &&
      try(length(var.workload_identity.description), 0) <= 256
    )
    error_message = "The workload_identity_pool_id must be empty or a valid Workload Identity name or id."
  }
  description = <<-EOD
    An optional identifier of an *existing* Workload Identity pool to which a new provider for NGINXaaS will be created.
    The optional name, display_name, and description values can be used to override the default values.
    EOD
}

variable "secrets" {
  type     = set(string)
  nullable = true
  validation {
    condition     = var.secrets == null ? true : alltrue([for secret in var.secrets : can(regex("projects/[a-z][a-z0-9-]{4,28}[a-z0-9]/secrets/[a-zA-Z0-9_-]{1,255}$", secret))])
    error_message = "Each secrets entry must be a valid Secret Manager self-link or name."
  }
  default     = null
  description = <<-EOD
  A set of Secret Manager secret identities that will be granted read-only access to principals which are entitled
  through the NGINXaaS OIDC provider.
  EOD
}

variable "service_accounts" {
  type     = set(string)
  nullable = true
  validation {
    condition     = try(length(var.service_accounts), 0) == 0 ? true : alltrue([for service_account in var.service_accounts : can(regex("^[1-9][0-9]+$", service_account))])
    error_message = "Each service_accounts entry must be a valid service attachment numeric id."
  }
  default     = null
  description = <<-EOD
  An optional set of service account identifiers, as provided by F5 NGINXaaS for Google Cloud. These accounts will be
  permitted to authenticated through an OIDC provider and granted access to send logs and metrics to the host project.
  The accounts will also be granted read-only access to Secret Manager secrets as set in `secrets` variable.
  EOD
}
