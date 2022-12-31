resource "google_compute_firewall" "masters_to_workers" {
  depends_on = [
    google_container_cluster.cluster
  ]
  name    = "gke-${google_container_cluster.cluster.name}-masters-to-workers"
  project = var.cluster.project
  network = var.cluster.network

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  source_ranges = [google_container_cluster.cluster.private_cluster_config[0].master_ipv4_cidr_block]
  target_tags   = ["gke-${google_container_cluster.cluster.name}"]
}