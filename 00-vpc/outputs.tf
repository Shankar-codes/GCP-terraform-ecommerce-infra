output "vpc_name" {
  value = google_compute_network.ecommerce_vpc.name
}

output "vpc_id" {
  value = google_compute_network.ecommerce_vpc.id
}

output "public_subnet" {
  value = google_compute_subnetwork.public.name
}

output "private_subnet" {
  value = google_compute_subnetwork.private.name
}

output "router_name" {
  value = google_compute_router.ecommerce_router.name
}

output "nat_name" {
  value = google_compute_router_nat.ecommerce_nat.name
}

output "load_balancer_ip" {
  value = google_compute_global_address.web.address
}

output "instance_group" {
  value = google_compute_region_instance_group_manager.web.instance_group
}