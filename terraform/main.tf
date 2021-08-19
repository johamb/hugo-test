provider "google" {
  project = var.project_id
  region  = var.project_region
  zone    = "${var.project_region}-${var.project_zone}"
}

