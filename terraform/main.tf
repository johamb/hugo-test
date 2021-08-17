provider "google" {
  project = var.project_id
  region  = var.project_region
  zone    = "${var.project_region}-${var.project_zone}"
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
    origin          = ["https://${var.domain}", "https://www.${var.domain}"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
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

  default_service = google_compute_backend_service.https.id

  host_rule {
    hosts        = [var.domain]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.https.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.https.id
    }
  }
}

resource "google_compute_backend_service" "https" {
  name        = "backend-service"
  port_name   = "http"
  protocol    = "HTTP"
  timeout_sec = 10

  health_checks = [google_compute_http_health_check.https.id]
}

resource "google_compute_http_health_check" "https" {
  name               = "http-health-check"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}
