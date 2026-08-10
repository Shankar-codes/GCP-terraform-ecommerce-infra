# service account creation
resource "google_service_account" "web" {
  account_id   = "web-server-sa"
  display_name = "Web Server Service Account"
}

resource "google_compute_instance_template" "web" {
  name_prefix  = "web-template-"
  machine_type = "e2-micro"

  disk {
    source_image = "debian-cloud/debian-12"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private.id # no public ip
  }

  service_account {
    email  = google_service_account.web.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash

    apt-get update
    apt-get install -y nginx

    systemctl enable nginx
    systemctl start nginx

    HOSTNAME=$(hostname)

    cat > /var/www/html/index.html <<HTML
    <html>
      <body>
        <h1>GCP DevOps Platform</h1>
        <h2>Server: $HOSTNAME</h2>
      </body>
    </html>
    HTML
  EOF

  tags = ["web-server"]
}

# MIG (Managed instance group) creation
# auto scaling creation
resource "google_compute_region_instance_group_manager" "web" {
  name               = "web-mig"
  region             = var.region
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