# Create a new instance
resource "google_compute_instance" "cos-stable-builder" {
  name         = "cos-stable-builder"
  machine_type = "n1-standard-1"
  zone         = "europe-west4-a"

  boot_disk {
    initialize_params {
      image = "docker"
    }
  }

  network_interface {
    network       = "default"
    access_config = {}
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }

  metadata {
    sshKeys     = "${var.gce_ssh_user}:${file(var.credentials_file_path)}"
    environment = "Production"
    app         = "CJE2"
  }

  metadata_startup_script = "pwd && ls -lath"
}
