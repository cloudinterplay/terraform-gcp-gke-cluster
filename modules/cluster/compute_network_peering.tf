resource "google_compute_network_peering_routes_config" "master_peering" {
  depends_on = [
    google_container_cluster.cluster
  ]
  export_custom_routes = true
  import_custom_routes = false
  network              = var.network
  peering              = google_container_cluster.cluster.private_cluster_config[0].peering_name
}