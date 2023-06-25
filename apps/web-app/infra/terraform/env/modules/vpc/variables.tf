variable "env" {
  type        = string
  description = "The environment the resources are being provisioned for."
  validation {
    condition     = can(regex("^(dev|prd)$", var.env))
    error_message = "The environment must be one of (dev|prd)."
  }
}

variable "google_project_id" {
  type        = string
  description = "The project id in which the resources should be created."
}

variable "region" {
  type        = string
  description = "The GCP Region in which the resources should be created."
}
