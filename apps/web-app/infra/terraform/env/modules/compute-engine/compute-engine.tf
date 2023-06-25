resource "google_compute_global_address" "cluster_ingress" {
  name    = "${var.google_project_id}-cluster-ingress"
  project = var.google_project_id
}
