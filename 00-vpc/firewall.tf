resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.ecommerce_vpc.id

  direction = "INGRESS"

  source_ranges = [
    "10.10.0.0/16"
  ]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }
}

# SSH firewall
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.ecommerce_vpc.id

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}

# port 80 firewall for nginx web server
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.ecommerce_vpc.id

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}

# load balancer firewall
resource "google_compute_firewall" "allow_web_lb" {
  name    = "allow-web-lb"
  network = google_compute_network.ecommerce_vpc.id

  direction = "INGRESS"

  target_tags = ["web-server"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}