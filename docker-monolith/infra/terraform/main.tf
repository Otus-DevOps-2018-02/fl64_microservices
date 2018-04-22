provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

### External IP
#resource "google_compute_address" "dockerhost_ip" {
#  name = "dockerhost-ip"
#}

### App Instance settings
resource "google_compute_instance" "dockerhost" {
  count = "${var.dockerhost_count}" # Create two instances

  #name         = "reddit-app-${count.index}" #Uniq name
  name         = "docker-host-${count.index}"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  tags         = ["docker-host"]

  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  network_interface {
    network = "default"

    access_config = {
      #  nat_ip = "${google_compute_address.dockerhost_ip.address}"
    }
  }

  metadata {
    ssh-keys = "dockerhost:${file(var.public_key_path)}"
  }
}

### Docker port
resource "google_compute_firewall" "fw_dockerhost" {
  name    = "allow-docker-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["2376"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["docker-host"]
}

### Docker port
resource "google_compute_firewall" "app_dockerhost" {
  name    = "allow-puma-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["docker-host"]
}

### Docker port
resource "google_compute_firewall" "ssh_dockerhost" {
  name    = "allow-ssh-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["docker-host"]
}
