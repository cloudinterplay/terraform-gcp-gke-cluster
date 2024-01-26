# Variables related to cluster it-self
variable "cluster" {
  description = "Cluster parameters"
  type = object({
    # The name of the cluster, unique within the project and location.
    name = string
    # Description of the cluster.
    description = optional(string, null)
    # (Optional) The ID of the project in which the resource belongs.
    project = string
    # The location (region or zone) in which the cluster master will be created, as well as the default node location.
    location = string
    # Structure addons_config
    addons_config = optional(object({
      # (Optional) The status of the HTTP (L7) load balancing controller addon, which makes it easy to set up HTTP load balancers for services in a cluster.
      http_load_balancing = optional(object({
        disabled = bool
      }), null)
      # (Optional) The status of the Horizontal Pod Autoscaling addon, which increases or decreases the number of replica pods a replication controller has based on the resource usage of the existing pods.
      horizontal_pod_autoscaling = optional(object({
        disabled = bool
      }), null)
      # (Optional) Whether we should enable the network policy addon for the master.
      network_policy_config = optional(object({
        disabled = bool
      }), null)
      # (Optional). The status of the NodeLocal DNSCache addon. It is disabled by default.
      dns_cache_config = optional(object({
        enabled = bool
      }), null)
      # (Optional) The status of the Filestore CSI driver addon, which allows the usage of filestore instance as volumes.
      gcp_filestore_csi_driver_config = optional(object({
        enabled = bool
      }), null)
    }), null)
    # (Optional) The IP address range of the Kubernetes pods in this cluster in CIDR notation (e.g. 10.96.0.0/14).
    cluster_ipv4_cidr = optional(string, null)
    # (Optional) Configuration for private clusters, clusters with private nodes.
    private_cluster_config = optional(object({
      enable_private_endpoint = bool
      enable_private_nodes    = bool
      master_ipv4_cidr_block  = string
    }), null)
    # (Optional) The number of nodes to create in this cluster's default node pool.
    initial_node_count = optional(number, 1)
    # (Optional) Configuration of cluster IP allocation for VPC-native clusters.
    ip_allocation_policy = optional(object({
      cluster_ipv4_cidr_block  = string
      services_ipv4_cidr_block = string
      stack_type               = optional(string,null)
    }), null)
    # The logging service that the cluster should write logs to. Available options include logging.googleapis.com, logging.googleapis.com/kubernetes (beta), and none
    logging_service = optional(string, null)
    # The CIDR block where HTTPS access is allowed from
    master_authorized_networks_config = optional(object({
      cidr_blocks = list(object({
        cidr_block   = string
        display_name = string
      }))
    }), null)
    # The monitoring service that the cluster should write metrics to. Automatically send metrics from pods in the cluster to the Google Cloud Monitoring API. VM metrics will be collected by Google Compute Engine regardless of this setting Available options include monitoring.googleapis.com, monitoring.googleapis.com/kubernetes (beta) and none
    monitoring_service = optional(string, null)
    # (Optional) The name or self_link of the Google Compute Engine network to which the cluster is connected.
    network = optional(string, null)
    # (Optional) Configuration options for the NetworkPolicy feature.
    network_policy = optional(object({
      enabled  = bool
      provider = string
    }), null)
    # (Optional) The name or self_link of the Google Compute Engine subnetwork in which the cluster's instances are launched.
    subnetwork = optional(string, null)
    # Vertical Pod Autoscaling automatically adjusts the resources of pods controlled by it
    vertical_pod_autoscaling = optional(object({
      enable = bool
    }), null)
    # Configuration options for the Binary Authorization feature.
    binary_authorization = optional(object({
      evaluation_mode = string
    }), null)
    # (Optional) Parameters used in creating the node pool.
    node_config = optional(object({
      enable          = optional(bool, false)
      image_type      = optional(string, "COS_CONTAINERD")
      machine_type    = optional(string, "e2-micro")
      service_account = optional(string, null)
      disk_size_gb    = optional(number, 10)
      disk_type       = optional(string, "pd-standard")
      spot            = optional(bool, false)
    }), null)
    release_channel = optional(object({
      enable  = optional(bool, false)
      channel = optional(string, "REGULAR")
    }), null)
    remove_default_node_pool = optional(bool, false)
  })
}
variable "node_pools" {
  description = "List of maps containing node pools"
  type = list(object({
    name = string
    autoscaling = optional(object({
      min_count       = optional(number, 1)
      max_count       = optional(number, 2)
      location_policy = optional(string, "BALANCED")
      total_min_count = optional(string, null)
      total_max_count = optional(string, null)
    }), {})
    initial_node_count = optional(number, null)
    node_config = optional(object({
      image_type      = optional(string, "COS_CONTAINERD")
      machine_type    = optional(string, "e2-micro")
      service_account = optional(string, null)
      disk_size_gb    = optional(number, 10)
      disk_type       = optional(string, "pd-standard")
      spot            = optional(bool, false)
    }), {})
  }))

  default = [
    {
      name = "default-pool"
    },
  ]
}
variable "node_pools_labels" {
  type        = map(map(string))
  description = "Map of maps containing node labels by node-pool name"

  # Default is being set in variables_defaults.tf
  default = {
    all               = {}
    default-node-pool = {}
  }
}
variable "node_pools_taints" {
  type        = map(list(object({ key = string, value = string, effect = string })))
  description = "Map of lists containing node taints by node-pool name"

  # Default is being set in variables_defaults.tf
  default = {
    all               = []
    default-node-pool = []
  }
}
variable "node_pools_tags" {
  type        = map(list(string))
  description = "Map of lists containing node network tags by node-pool name"

  # Default is being set in variables_defaults.tf
  default = {
    all               = []
    default-node-pool = []
  }
}
variable "node_pools_oauth_scopes" {
  type        = map(list(string))
  description = "Map of lists containing node oauth scopes by node-pool name"

  # Default is being set in variables_defaults.tf
  default = {
    all               = ["https://www.googleapis.com/auth/cloud-platform"]
    default-node-pool = []
  }
}