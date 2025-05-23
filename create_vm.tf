provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_instance" "my-first-vm" {
  name         = "my-first-vm"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }
}