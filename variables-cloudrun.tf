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

variable "version_label" {
  description = "Label for the App Engine version."
  type        = string
}

variable "absolute_path" {
  description = "Absolute path to the application source code."
  type        = string
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