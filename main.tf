resource "google_service_account" "default" {
  account_id   = var.service_account
  display_name = "Service Account"
}

resource "google_container_cluster" "app_cluster" {
  name     = var.cluster_name
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.cluster_ipv4_cidr_block
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }
  network    = var.network
  subnetwork = var.subnetwork

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00"
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = var.authorized_ipv4_cidr_block != null ? [var.authorized_ipv4_cidr_block] : []
    content {
      cidr_blocks {
        cidr_block   = master_authorized_networks_config.value
        display_name = "External Control Plane access"
      }
    }
  }

  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  release_channel {
    channel = "STABLE"
  }

  addons_config {
    // Enable network policy (Calico)
    network_policy_config {
      disabled = false
    }
  }

  /* Enable network policy configurations (like Calico).
  For some reason this has to be in here twice. */
  network_policy {
    enabled = "true"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_compute_network_peering_routes_config" "master_peering" {
  export_custom_routes = true
  import_custom_routes = false
  network              = var.network
  peering              = google_container_cluster.app_cluster.private_cluster_config[0].peering_name

  depends_on = [google_container_cluster.app_cluster]
}

resource "google_container_node_pool" "app_cluster_linux_node_pool" {
  name           = "${google_container_cluster.app_cluster.name}--linux-node-pool"
  location       = google_container_cluster.app_cluster.location
  node_locations = var.node_zones
  cluster        = google_container_cluster.app_cluster.name
  node_count     = 1

  autoscaling {
    max_node_count = var.node_pool.autoscaling.max_node_count
    min_node_count = var.node_pool.autoscaling.min_node_count
  }
  max_pods_per_node = 100

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = var.node_pool.node_config.preemptible
    machine_type = var.node_pool.node_config.machine_type
    image_type   = var.node_pool.node_config.image_type
    disk_size_gb = var.node_pool.node_config.disk_size_gb

    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]

    labels = {
      cluster = google_container_cluster.app_cluster.name
    }

    tags = [
      "gke-${google_container_cluster.app_cluster.name}",
      // For fw-Allow-Proxy
      "container-node-pool"
    ]

    shielded_instance_config {
      enable_secure_boot = true
    }

    // Enable workload identity on this node pool.
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    metadata = {
      // Set metadata on the VM to supply more entropy.
      google-compute-enable-virtio-rng = "true"
      // Explicitly remove GCE legacy metadata API endpoint.
      disable-legacy-endpoints = "true"
    }
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 1
  }
}

resource "google_compute_firewall" "masters_to_workers" {
  depends_on = [
    google_container_cluster.app_cluster
  ]
  name    = "gke-${google_container_cluster.app_cluster.name}-masters-to-workers"
  project = var.project_id
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  source_ranges = [google_container_cluster.app_cluster.private_cluster_config[0].master_ipv4_cidr_block]
  target_tags   = ["gke-${google_container_cluster.app_cluster.name}"]
}