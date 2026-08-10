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