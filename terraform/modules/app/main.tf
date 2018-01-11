data "template_file" "pumaservice" {
  template = "${file("${path.module}/files/puma.service.tpl")}"

  vars {
    db_addr = "${var.db_addr}"
  }
}

/*
data "template_file" "envvars" {
  template = "${file("${path.module}/files/env_vars.sh.tpl")}"

  vars {
    db_addr = "${var.db_addr}"
  }
}
*/

/*
data "template_file" "deploy" {
  template = "${file("${path.module}/files/deploy.sh.tpl")}"

  vars {
    db_addr = "${var.db_addr}"
  }
}
*/

resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  network_interface {
    network = "default"

    access_config = {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  metadata {
    sshKeys = "appuser:${file(var.public_key_path)}"
  }

  connection {
    type        = "ssh"
    user        = "appuser"
    agent       = false
    private_key = "${file(var.private_key_path)}"
  }

/*
  provisioner "file" {
    source = "${path.module}/files/puma.service"
    destination = "/tmp/puma.service"
  }
*/

/*
  provisioner "file" {
    content      = "${data.template_file.envvars.rendered}"
    destination = "/tmp/env_vars.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/env_vars.sh",
      "/tmp/env_vars.sh",
      "echo done > /tmp/env_done.txt",
    ]
  }
*/

/*
  provisioner "file" {
    content      = "${data.template_file.deploy.rendered}"
    destination = "/tmp/deploy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/deploy.sh",
      "/tmp/deploy.sh",
    ]
  }
*/

  provisioner "file" {
    content     = "${data.template_file.pumaservice.rendered}"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }

}

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}
