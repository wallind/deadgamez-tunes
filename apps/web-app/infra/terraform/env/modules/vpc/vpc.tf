# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.google_project_id}-vpc"
  auto_create_subnetworks = "false"
  project                 = var.google_project_id
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.google_project_id}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
  project       = var.google_project_id
}
