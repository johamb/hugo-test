provider "google" {
  project = var.project_id
  region  = var.project_region
  zone    = var.project_region + "-" + var.project_zone
}

resource "google_storage_bucket" "static-site" {
  name          = var.domain
  location      = var.project_location
  force_destroy = true

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  cors {
    origin          = ["https://" + var.domain]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}