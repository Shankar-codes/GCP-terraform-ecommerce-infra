# vpc creation
resource "google_compute_vpc" "ecommerce_vpc" {
  name = "ecommerce-vpc"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

# public subnet creation
resource "google_compute_subnetwork" "public" {
  name          = "public-subnet"
  ip_cidr_range = var.public_subnet_cidr
  region        = var.region
  network       = google_compute_network.ecommerce_vpc.id
}

# private subnet creation
resource "google_compute_subnetwork" "private" {
  name          = "private-subnet"
  ip_cidr_range = var.private_subnet_cidr
  region        = var.region
  network       = google_compute_network.ecommerce_vpc.id
}

# router creation
resource "google_compute_router" "ecommerce_router" {
  name    = "ecommerce-router"
  network = google_compute_network.ecommerce_vpc.id
  region  = var.region
}
