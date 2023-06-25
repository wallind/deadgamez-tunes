## Create new storage bucket in the US multi-region
## with standard storage
resource "google_storage_bucket" "terraform_state_bucket" {
  name          = "${var.google_project_id}-terraform-remote-state"
  force_destroy = true

  location      = "US"
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
  project                     = var.google_project_id

  public_access_prevention = "enforced"
}
