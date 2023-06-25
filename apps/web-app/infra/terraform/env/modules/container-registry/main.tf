terraform {
  required_version = "1.5.1"
}


// │ Error: Request `Enable Project Service "compute.googleapis.com " for project ""` returned error:
// failed to send enable services request: googleapi: Error 403: Not found or permission denied for service(s): compute.googleapis.com .

#resource "google_project_service" "enable_container_registry" {
#  project = var.google_project_id
#  service = "containerregistry.googleapis.com"
#}
