# ============================================================
# Service Account
# ============================================================

resource "google_service_account" "web" {
  account_id   = "web-server-sa"
  display_name = "Web Server Service Account"
}


# ============================================================
# Compute Engine Instance Template
# ============================================================

resource "google_compute_instance_template" "web" {
  name_prefix  = "web-template-"
  machine_type = "e2-micro"

  # Boot Disk
  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }

  # Network Interface
  # No access_config block = No Public IP
  network_interface {
    subnetwork = google_compute_subnetwork.private.id
  }

  # Service Account
  service_account {
    email  = google_service_account.web.email
    scopes = ["cloud-platform"]
  }

  # Startup Script
  metadata_startup_script = <<-EOF
    #!/bin/bash

    set -euxo pipefail

    # Send startup script output to a log file
    exec > >(tee /var/log/startup-script.log | logger -t startup-script -s 2>/dev/console) 2>&1

    echo "=========================================="
    echo "GCP Web Server Startup Script Started"
    echo "=========================================="

    # Update package repository
    echo "Updating packages..."
    apt-get update

    # Install Nginx
    echo "Installing Nginx..."
    apt-get install -y nginx

    # Enable Nginx at boot
    echo "Enabling Nginx..."
    systemctl enable nginx

    # Start Nginx
    echo "Starting Nginx..."
    systemctl restart nginx

    # Get hostname
    SERVER_NAME=$$(hostname)

    # Create test web page
    cat > /var/www/html/index.html <<HTML
    <html>
      <head>
        <title>GCP DevOps Project</title>
      </head>

      <body>
        <h1>GCP DevOps Platform</h1>
        <h2>Server: $${SERVER_NAME}</h2>
        <p>Nginx is running successfully.</p>
      </body>
    </html>
    HTML

    echo "=========================================="
    echo "Nginx Installation Completed"
    echo "Server: $${SERVER_NAME}"
    echo "=========================================="
  EOF

  # Network tag used by firewall rules
  tags = ["web-server"]
}


# ============================================================
# Regional Managed Instance Group
# ============================================================

resource "google_compute_region_instance_group_manager" "web" {
  name   = "web-mig"
  region = var.region

  # Specify zones explicitly.
  #
  # We removed us-central1-c and us-central1-f because
  # your previous VM creation failed with:
  #
  # ZONE_RESOURCE_POOL_EXHAUSTED
  #
  distribution_policy_zones = [
    "us-central1-a",
    "us-central1-b"
  ]

  base_instance_name = "web"

  # Instance Template
  version {
    instance_template = google_compute_instance_template.web.id
  }

  # Desired number of instances
  target_size = 2

  # Auto Healing
  auto_healing_policies {
    health_check      = google_compute_health_check.web.id
    initial_delay_sec = 120
  }
}


# ============================================================
# Regional Autoscaler
# ============================================================

resource "google_compute_region_autoscaler" "web" {
  name   = "web-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.web.id

  autoscaling_policy {
    # Minimum number of VMs
    min_replicas = 2

    # Maximum number of VMs
    max_replicas = 5

    # Wait time before starting another scaling decision
    cooldown_period = 60

    # Scale based on CPU utilization
    cpu_utilization {
      target = 0.60
    }
  }
}