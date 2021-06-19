provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_container_cluster" "primary" {
  name               = "cluster"
  zone               = "${var.zone}"
  initial_node_count = "${var.initial_node_count}"
  min_master_version = "${var.gke_version}"
  node_version       = "${var.gke_version}"
  enable_legacy_abac = true #def = false
  monitoring_service = "none" # hw26
  logging_service    = "none" # hw26

  node_config {

    disk_size_gb = "${var.disk_size}"
    machine_type = "${var.machine_type}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

  }
}

resource "google_compute_firewall" "kuber_fw_apps" {
  name    = "gke"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  description   = "kuber apps"
  source_ranges = ["0.0.0.0/0"]
}