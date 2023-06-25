resource "google_container_cluster" "primary" {
  project  = var.google_project_id
  name     = "${var.google_project_id}-gke"
  location = var.gke_cluster_zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.cluster_vpc_name
  subnetwork = var.cluster_subnet_name
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  project    = var.google_project_id
  name       = google_container_cluster.primary.name
  location   = var.gke_cluster_zone
  cluster    = google_container_cluster.primary.name
  node_count = 2

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.env
    }

    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${var.google_project_id}-gke"]
    metadata     = {
      disable-legacy-endpoints = "true"
    }
  }
}

module "cert_manager" {
  source = "terraform-iaac/cert-manager/kubernetes"

  cluster_issuer_private_key_secret_name = "cert-manager-private-key"

  cluster_issuer_create = false
  #  NOT USED
  cluster_issuer_server = "https://acme-staging-v02.api.letsencrypt.org/directory"
  cluster_issuer_email  = "DUMMYVAL@mail.com"
}

# Provider is configured using environment variables: GOOGLE_REGION, GOOGLE_PROJECT, GOOGLE_CREDENTIALS.
# This can be set statically, if preferred. See docs for details.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#full-reference

# Configure kubernetes provider with Oauth2 access token.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
# This fetches a new token, which will expire in 1 hour.
data "google_client_config" "primary" {
  depends_on = [google_container_cluster.primary]
}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.primary.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.primary.access_token
    cluster_ca_certificate = base64decode(
      google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
    )
  }
}
provider "kubectl" {
  load_config_file       = false
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.primary.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
  )
}
