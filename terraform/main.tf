provider "google" {
  project = var.project_id
  region  = var.project_region
  zone    = "${var.project_region}-${var.project_zone}"
}

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

resource "google_storage_default_object_access_control" "static-site" {
  bucket = google_storage_bucket.static-site.name
  role   = "READER"
  entity = "allUsers"
}

resource "google_compute_target_https_proxy" "https" {
  name             = "https-proxy"
  url_map          = google_compute_url_map.https.id
  ssl_certificates = [google_compute_managed_ssl_certificate.https.id]
}

resource "google_compute_managed_ssl_certificate" "https" {
  name = "ssl-certificate"

  managed {
    domains = [var.domain]
  }
}

resource "google_compute_url_map" "https" {
  name        = "url-map"
  description = "a description"

  default_service = google_compute_backend_bucket.static-site.id

  host_rule {
    hosts        = [var.domain]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_bucket.static-site.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_bucket.static-site.id
    }
  }
}

resource "google_compute_backend_bucket" "static-site" {
  name        = "hugo-test-bucket"
  bucket_name = google_storage_bucket.static-site.name
  enable_cdn  = true
}

resource "google_compute_http_health_check" "static-site" {
  name               = "http-health-check"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}

resource "google_compute_global_address" "static-ip" {
  name     = "static-ip"
}

resource "google_compute_global_forwarding_rule" "static-site" {
  name                  = "static-site-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.static-ip.address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.https.self_link
}