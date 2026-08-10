# Health check configuration for the load balancer
resource "google_compute_health_check" "web" {
  name = "web-health-check"

  http_health_check {
    port         = 80
    request_path = "/"
  }

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
}

