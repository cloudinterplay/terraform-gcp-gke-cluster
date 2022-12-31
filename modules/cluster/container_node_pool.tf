resource "google_container_node_pool" "pools" {
  depends_on = [
    google_container_cluster.cluster
  ]
  for_each = { for np in var.node_pools : np.name => np }
  cluster  = google_container_cluster.cluster.name
  location = google_container_cluster.cluster.location
  name     = each.value.name
  autoscaling {
    min_node_count       = each.value.autoscaling.min_count
    max_node_count       = each.value.autoscaling.max_count
    location_policy      = each.value.autoscaling.location_policy
    total_min_node_count = each.value.autoscaling.total_min_count
    total_max_node_count = each.value.autoscaling.total_max_count
  }
  initial_node_count = each.value.initial_node_count

  node_config {
    image_type   = each.value.node_config.image_type
    machine_type = each.value.node_config.machine_type
    disk_size_gb = each.value.node_config.disk_size_gb
    disk_type    = each.value.node_config.disk_type
    spot         = each.value.node_config.spot

    service_account = each.value.node_config.service_account == null ? google_service_account.cluster_service_account.email : each.value.node_config.service_account

    tags = concat(
      lookup(local.node_pools_tags, "default_values", [true, true])[0] ? [local.cluster_network_tag] : [],
      lookup(local.node_pools_tags, "default_values", [true, true])[1] ? ["${local.cluster_network_tag}-${each.value["name"]}"] : [],
      local.node_pools_tags["all"],
      local.node_pools_tags[each.value["name"]],
    )
  }
}