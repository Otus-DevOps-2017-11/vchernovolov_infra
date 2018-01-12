provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = "${var.app_zone}"

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой подсоединить данный интерфейса
    network = "default"

    # использовать ephemera IP для доступа из Интернет
    access_config {}
  }

  # metadata!
  metadata {
    sshKeys = "appuser:${file(var.public_key_path)}"
  }

  # теги инстанса
  tags = ["reddit-app"]

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"

  # название сети, в которой действует правило
  network = "default"

  # какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  # каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]

  # данное правило применимо для инстансов с тегом
  target_tags = ["reddit-app"]
}
