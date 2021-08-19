resource "google_compute_managed_ssl_certificate" "certificate" {
  name = "ssl-certificate"

  managed {
    domains = [var.domain, "www.${var.domain}"]
  }
}

resource "google_compute_global_address" "static-ip" {
  name     = "static-ip"
}

resource "google_compute_target_https_proxy" "https" {
  name             = "https-proxy"
  url_map          = google_compute_url_map.https.id
  ssl_certificates = [google_compute_managed_ssl_certificate.certificate.id]
}

resource "google_compute_target_http_proxy" "http" {
  name    = "http-proxy"
  url_map = google_compute_url_map.https-redirect.self_link
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

resource "google_compute_url_map" "https-redirect" {
  name = "https-redirect"

  default_url_redirect {
    https_redirect         = true
    strip_query            = false
    redirect_response_code = "PERMANENT_REDIRECT"
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

resource "google_compute_global_forwarding_rule" "https" {
  name                  = "static-site-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.static-ip.address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.https.self_link
}

resource "google_compute_global_forwarding_rule" "http" {
  name        = "http"
  target      = google_compute_target_http_proxy.http.self_link
  ip_address  = google_compute_global_address.static-ip.address
  ip_protocol = "TCP"
  port_range  = "80"
}