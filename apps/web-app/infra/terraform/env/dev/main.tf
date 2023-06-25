terraform {
  backend "gcs" {
    bucket = "#GOOGLE_PROJECT_ID#-terraform-remote-state"
    prefix = "terraform/state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

locals {
  env               = "dev"
  google_project_id = "#GOOGLE_PROJECT_ID#"
  gcp_region        = "#GOOGLE_REGION#"
  gke_cluster_zone  = "#GOOGLE_CLUSTER_ZONE#"
}

module "compute_engine" {
  source = "../modules/compute-engine"

  env               = local.env
  google_project_id = local.google_project_id
}

module "container-registry" {
  source = "../modules/container-registry"

  env               = local.env
  google_project_id = local.google_project_id
}

module "gcs" {
  source = "../modules/gcs"

  env               = local.env
  google_project_id = local.google_project_id
}

module "vpc" {
  source = "../modules/vpc"

  env               = local.env
  google_project_id = local.google_project_id
  region            = local.gcp_region
}

module "gke" {
  source = "../modules/gke"

  env               = local.env
  google_project_id = local.google_project_id
  gke_cluster_zone  = local.gke_cluster_zone

  cluster_vpc_name    = module.vpc.vpc_name
  cluster_subnet_name = module.vpc.subnet_name
}
