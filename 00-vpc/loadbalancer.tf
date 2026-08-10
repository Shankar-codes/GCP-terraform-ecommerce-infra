#load balancer creation
resource "google_compute_backend_service" "web" {
  name                  = "web-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  health_checks = [
    google_compute_health_check.web.id
  ]

  backend {
    group           = google_compute_region_instance_group_manager.web.instance_group
    balancing_mode  = "UTILIZATION"
    max_utilization = 0.80
  }
}

resource "google_compute_url_map" "web" {
  name            = "web-url-map"
  default_service = google_compute_backend_service.web.id
}

resource "google_compute_target_http_proxy" "web" {
  name    = "web-http-proxy"
  url_map = google_compute_url_map.web.id
}