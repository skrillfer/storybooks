provider "google" {
  credentials = file("terraform-sa-key.json")
  project = "devops-0794-personal"
  region = "us-central-1"
  zone = "us-central1-c"
}

# IP ADDRESS
resource "google_compute_address" "ip_address" {
  name = "storybooks-ip-${terraform.workspace}"
}
# NETWORK
data "google_compute_network" "default" {
  name = "default"
}

# FIREWALL RULE
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-${terraform.workspace}"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["allow-http-${terraform.workspace}"]
}

# OS IMAGE
data "google_compute_image" "cos_image" {
  family = "cos-81-lts"
  project = "cos-cloud"
}
# COMPUTE ENGINE INSTANCE
# resource "google_service_account" "default" {
#   account_id   = "service_account_id"
#   display_name = "Service Account"
# }

resource "google_compute_instance" "instance" {
  name         = "${var.app_name}-vm-${terraform.workspace}"
  machine_type = var.gcp_machine_type
  zone         = "us-central1-a"

  tags = google_compute_firewall.allow_http.target_tags

  boot_disk {
    initialize_params {
      image = data.google_compute_image.cos_image.self_link
    }
  }

  network_interface {
    network = data.google_compute_network.default.name

    access_config {
      nat_ip = google_compute_address.ip_address.address
    }
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}