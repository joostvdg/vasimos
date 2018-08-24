module "controller" {
  source       = "modules/controller"
  machine_type = "${var.machine_type_controllers}"
  num          = "${var.num_controllers}"
  zone         = "${var.region_default_zone}"
  subnet       = "${var.subnet_name}"
}

module "worker" {
  source       = "modules/worker"
  machine_type = "${var.machine_type_workers}"
  num          = "${var.num_workers}"
  zone         = "${var.region_default_zone}"
  network      = "${google_compute_network.khw.name}"
  subnet       = "${var.subnet_name}"
}
