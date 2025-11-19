##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#
variable "namespace" {
  description = "Namespace for the App Engine application."
  type        = string
  default     = "default"
}

variable "region" {
  description = "GCP Region where App Engine will be created."
  type        = string
  default     = "us-central1"
}

variable "cloudrun" {
  description = "App Engine application configuration."
  type        = any
  default     = {}
}

variable "dns" {
  description = "DNS configuration for custom domains."
  type        = any
  default     = {}
}

variable "release" {
  description = "Release information for tagging and versioning."
  type        = any
  default     = {}
}

variable "observability" {
  description = "Observability configuration for monitoring and logging."
  type        = any
  default     = {}
}

variable "container_registry" {
  description = "Container Registry configuration for storing container images."
  type        = string
}

variable "deployment_sa" {
  description = "Service Account email for deploying Cloud Run services."
  type        = string
  default     = ""
  nullable    = false
}

variable "repository_owner" {
  description = "Owner of the source code repository."
  type        = string
}