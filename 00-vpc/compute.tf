# service account creation
resource "google_service_account" "web" {
  account_id   = "web-server-sa"
  display_name = "Web Server Service Account"
}

# Instance Template
resource "google_compute_instance_template" "web" {
  name_prefix  = "web-template-"
  machine_type = "e2-micro"

  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private.id
  }

  service_account {
    email  = google_service_account.web.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash

    set -euxo pipefail

    exec > >(tee /var/log/startup-script.log | logger -t startup-script -s 2>/dev/console) 2>&1

    echo "===== STARTUP SCRIPT STARTED ====="

    apt-get update

    apt-get install -y nginx

    systemctl enable nginx
    systemctl restart nginx

    SERVER_NAME=$$(hostname)

    cat > /var/www/html/index.html <<HTML
    <html>
      <body>
        <h1>GCP DevOps Platform</h1>
        <h2>Server: $${SERVER_NAME}</h2>
      </body>
    </html>
    HTML

    echo "===== STARTUP SCRIPT COMPLETED ====="
  EOF

  tags = ["web-server"]
}

# MIG (Managed instance group) creation
# auto scaling creation
resource "google_compute_region_instance_group_manager" "web" {
  name   = "web-mig"
  region = var.region

  distribution_policy_zones = [
    "us-central1-a",
    "us-central1-b"
  ]

  base_instance_name = "web"

  version {
    instance_template = google_compute_instance_template.web.id
  }

  target_size = 2

  auto_healing_policies {
    health_check      = google_compute_health_check.web.id
    initial_delay_sec = 120
  }
}