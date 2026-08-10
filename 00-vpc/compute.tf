# service account creation
resource "google_service_account" "web" {
  account_id   = "web-server-sa"
  display_name = "Web Server Service Account"
}