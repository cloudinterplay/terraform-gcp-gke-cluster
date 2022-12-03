resource "google_service_account" "default" {
  account_id   = "service-account-${var.cluster_name}"
  display_name = "Service Account"
}

resource "google_container_cluster" "cluster" {
  name     = var.cluster_name
  location = var.cluster_location

  addons_config {
    network_policy_config {
      disabled = false
    }
  }

  initial_node_count = var.cluster_initial_node_count

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.cluster_ip_allocation_policy.cluster_ipv4_cidr_block
    services_ipv4_cidr_block = var.cluster_ip_allocation_policy.services_ipv4_cidr_block
  }
  network    = var.cluster_network
  subnetwork = var.cluster_subnetwork

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00"
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = [var.cluster_master_authorized_networks_config]
    content {
      dynamic "cidr_blocks" {
        for_each = lookup(master_authorized_networks_config.value, "cidr_blocks", [])
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = lookup(cidr_blocks.value, "display_name", null)
        }
      }
    }
  }

  private_cluster_config {
    enable_private_endpoint = var.cluster_private_cluster_config.enable_private_endpoint
    enable_private_nodes    = var.cluster_private_cluster_config.enable_private_nodes
    master_ipv4_cidr_block  = var.cluster_private_cluster_config.master_ipv4_cidr_block
  }

  remove_default_node_pool = var.cluster_remove_default_node_pool

  release_channel {
    channel = "STABLE"
  }

  /* Enable network policy configurations (like Calico).
  For some reason this has to be in here twice. */
  network_policy {
    enabled = "true"
  }
  node_config {
    disk_size_gb    = var.cluster_node_config.disk_size_gb
    disk_type       = var.cluster_node_config.disk_type
    machine_type    = var.cluster_node_config.machine_type
    spot            = var.cluster_node_config.spot

    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      cluster = var.cluster_name
    }
    tags = ["gke-${var.cluster_name}"]
  }

  workload_identity_config {
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
  }
}

resource "google_compute_network_peering_routes_config" "master_peering" {
  export_custom_routes = true
  import_custom_routes = false
  network              = var.cluster_network
  peering              = google_container_cluster.cluster.private_cluster_config[0].peering_name

  depends_on = [google_container_cluster.cluster]
}

resource "google_compute_firewall" "masters_to_workers" {
  depends_on = [
    google_container_cluster.cluster
  ]
  name    = "gke-${google_container_cluster.cluster.name}-masters-to-workers"
  project = data.google_project.project.project_id
  network = var.cluster_network

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  source_ranges = [google_container_cluster.cluster.private_cluster_config[0].master_ipv4_cidr_block]
  target_tags   = ["gke-${google_container_cluster.cluster.name}"]
}