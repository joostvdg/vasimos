/*
gcloud compute instances create worker-${i} \
    --async \
    --boot-disk-size 200GB \
    --can-ip-forward \
    --image-family ubuntu-1804-lts \
    --image-project ubuntu-os-cloud \
    --machine-type n1-standard-1 \
    --metadata pod-cidr=10.200.${i}.0/24 \
    --private-network-ip 10.240.0.2${i} \
    --scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
    --subnet kubernetes \
    --tags kubernetes-the-hard-way,worker
    */

data "google_compute_image" "khw-ubuntu" {
  family  = "ubuntu-1804-lts"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "khw-worker" {
  count          = "${var.num}"
  name           = "worker-${count.index}"
  machine_type   = "${var.machine_type}"
  zone           = "${var.zone}"
  can_ip_forward = "true"

  tags = ["kubernetes-the-hard-way", "worker"]

  metadata {
    pod-cidr = "10.200.${count.index}.0/24"
  }

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.khw-ubuntu.self_link}"
      size  = 200                                                 // in GB
    }
  }

  network_interface {
    subnetwork = "${var.subnet}"
    address    = "10.240.0.2${count.index}"

    access_config {
      // Ephemeral External IP
    }
  }

  service_account {
    scopes = ["compute-rw",
      "storage-ro",
      "service-management",
      "service-control",
      "logging-write",
      "monitoring",
    ]
  }
}
