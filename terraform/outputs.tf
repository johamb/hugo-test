output "bucket_url" {
  value = google_storage_bucket.static-site.url
}

output "load_balancer_ip" {
  value = google_compute_global_address.static-ip.address
}