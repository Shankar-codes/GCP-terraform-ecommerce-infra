resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.ecommerce_vpc.name

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
  network = google_compute_network.ecommerce_vpc.name

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
  network = google_compute_network.ecommerce_vpc.name

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}