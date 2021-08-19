resource "google_storage_bucket" "static-site" {
  name          = var.domain
  location      = var.project_location
  force_destroy = true

  uniform_bucket_level_access = false

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  cors {
    origin          = ["https://${var.domain}", "https://www.${var.domain}"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

### WARNING ###
# this will make all files uploaded to the storage publicly accessible by default
resource "google_storage_default_object_access_control" "static-site" {
  bucket = google_storage_bucket.static-site.name
  role   = "READER"
  entity = "allUsers"
}
### WARNING END ###