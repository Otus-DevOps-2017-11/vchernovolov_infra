output "db_addr_int" {
  value = "${google_compute_instance.db.network_interface.0.network_ip}"
}
