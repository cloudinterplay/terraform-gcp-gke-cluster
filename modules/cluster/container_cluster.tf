resource "google_container_cluster" "cluster" {
  name        = var.name
  description = var.description
  project     = var.project

  location          = var.location
  node_locations    = var.node_locations

  dynamic addons_config {
    for_each = coalesce(
      var.http_load_balancing == null ? "" : true,
      var.horizontal_pod_autoscaling == null ? "" : true,
      var.network_policy_config == null ? "" : true,
      var.dns_cache_config == null ? "" : true,
      var.gcp_filestore_csi_driver_config == null ? "" : true,false) ? [1] : []
    content {
      dynamic "http_load_balancing" {
        for_each = var.http_load_balancing != null ? [var.http_load_balancing] : []
        content {
          disabled = http_load_balancing.value.disabled
        }
      }
      dynamic "horizontal_pod_autoscaling" {
        for_each = var.horizontal_pod_autoscaling != null ? [var.horizontal_pod_autoscaling] : []
        content {
          disabled = horizontal_pod_autoscaling.value.disabled
        }
      }
      dynamic "network_policy_config" {
        for_each = var.network_policy_config != null ? [var.network_policy_config] : []
        content {
          disabled = network_policy_config.value.disabled
        }
      }
      dynamic "dns_cache_config" {
        for_each = var.dns_cache_config != null ? [var.dns_cache_config] : []
        content {
          enabled = dns_cache_config.value.enabled
        }
      }
      dynamic "gcp_filestore_csi_driver_config" {
        for_each = var.gcp_filestore_csi_driver_config != null ? [var.gcp_filestore_csi_driver_config] : []
        content {
          enabled = gcp_filestore_csi_driver_config.value.enabled
        }
      }
    }
  }

  cluster_ipv4_cidr = var.cluster_ipv4_cidr

  dynamic cluster_autoscaling {
    for_each = var.cluster_autoscaling != null ? [var.cluster_autoscaling] : []
    content {
      enabled  = cluster_autoscaling.value.enabled
      dynamic resource_limits {
        for_each = lookup(var.cluster_autoscaling,"resource_limits",[])
        content {
          resource_type = resource_limits.value.resource_type
          minimum       = resource_limits.value.minimum
          maximum       = resource_limits.value.maximum
        }
      }
    }
  }

  default_max_pods_per_node = var.default_max_pods_per_node
  enable_shielded_nodes     = var.enable_shielded_nodes

  dynamic ip_allocation_policy {
    for_each = var.ip_allocation_policy != null ? [var.ip_allocation_policy] : []
    content {
      cluster_ipv4_cidr_block  = ip_allocation_policy.value.cluster_ipv4_cidr_block
      services_ipv4_cidr_block = ip_allocation_policy.value.services_ipv4_cidr_block
    }
  }
  logging_service    = var.logging_service
  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00"
    }
  }
  dynamic "master_authorized_networks_config" {
    for_each = var.master_authorized_networks_config != null ? [1] : []
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
  monitoring_service = var.monitoring_service
  network            = var.network
  dynamic "network_policy" {
    for_each = var.network_policy != null ? [var.network_policy] : []
    content {
      enabled  = network_policy.value.enabled
      provider = network_policy.value.provider
    }
  }
  subnetwork = var.subnetwork
  dynamic "vertical_pod_autoscaling" {
    for_each = var.vertical_pod_autoscaling != null ? [var.vertical_pod_autoscaling] : []
    content {
      enabled = vertical_pod_autoscaling.value.enabled
    }
  }
  dynamic "binary_authorization" {
    for_each = var.binary_authorization != null ? [var.binary_authorization] : []
    content {
      evaluation_mode = binary_authorization.value.evaluation_mode
    }
  }

  dynamic private_cluster_config {
    for_each = var.private_cluster_config != null ? [var.private_cluster_config] : []
      content {
        enable_private_endpoint = private_cluster_config.value.enable_private_endpoint
        enable_private_nodes    = private_cluster_config.value.enable_private_nodes
        master_ipv4_cidr_block  = private_cluster_config.value.master_ipv4_cidr_block
      }
  }
  node_pool {
    name               = "default-pool"
    initial_node_count = var.initial_node_count

    dynamic "autoscaling" {
      for_each = [lookup(var.node_pools[0], "autoscaling", [])]
      content {
        min_node_count       = autoscaling.value.min_count
        max_node_count       = autoscaling.value.max_count
        location_policy      = autoscaling.value.location_policy
        total_min_node_count = autoscaling.value.total_min_count
        total_max_node_count = autoscaling.value.total_max_count
      }
    }

    node_config {
      image_type       = lookup(var.node_pools[0], "image_type", "COS_CONTAINERD")
      machine_type     = lookup(var.node_pools[0], "machine_type", "e2-micro")
      min_cpu_platform = lookup(var.node_pools[0], "min_cpu_platform", "")
      dynamic "gcfs_config" {
        for_each = lookup(var.node_pools[0], "enable_gcfs", false) ? [true] : []
        content {
          enabled = gcfs_config.value
        }
      }

      dynamic "gvnic" {
        for_each = lookup(var.node_pools[0], "enable_gvnic", false) ? [true] : []
        content {
          enabled = gvnic.value
        }
      }

      service_account = lookup(var.node_pools[0], "service_account", google_service_account.cluster_service_account.email)

      tags = concat(
        lookup(local.node_pools_tags, "default_values", [true, true])[0] ? [local.cluster_network_tag] : [],
        lookup(local.node_pools_tags, "default_values", [true, true])[1] ? ["${local.cluster_network_tag}-default-pool"] : [],
        lookup(local.node_pools_tags, "all", []),
        lookup(local.node_pools_tags, var.node_pools[0].name, []),
      )

      dynamic "workload_metadata_config" {
        for_each = var.workload_metadata_config != null ? [1] : []
        content {
          mode = each.value.mode
        }
      }

      shielded_instance_config {
        enable_secure_boot          = lookup(var.node_pools[0], "enable_secure_boot", false)
        enable_integrity_monitoring = lookup(var.node_pools[0], "enable_integrity_monitoring", true)
      }
    }
  }
  remove_default_node_pool = var.remove_default_node_pool
  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }
}