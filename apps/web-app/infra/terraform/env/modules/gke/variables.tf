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

variable "gke_cluster_zone" {
  type        = string
  description = "The GCP Region in which the resources should be created."
}

variable "cluster_vpc_name" {
  type        = string
  description = "The nameof the VPC the cluster should use."
}

variable "cluster_subnet_name" {
  type        = string
  description = "The name of the subnet the cluster should use."
}
