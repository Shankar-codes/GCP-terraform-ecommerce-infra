# vpc creation
resource "google_compute_network" "ecommerce_vpc" {
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

# NAT creation for private subnet
resource "google_compute_router_nat" "ecommerce_nat" {
  name                               = "ecommerce-nat"
  router                             = google_compute_router.ecommerce_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

