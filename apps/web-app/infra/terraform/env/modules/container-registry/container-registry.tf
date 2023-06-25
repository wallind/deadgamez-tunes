resource "google_container_registry" "web_app_container_registry" {
  project  = var.google_project_id
  location = "US"
}
