# Each resource variable has prefix which indicate the resource it's related to.
# For example cluster{{ some variable}}, means variable for google_container_cluster

# Variables related to cluster it-self
variable "name" {
  description = "The name of the cluster, unique within the project and location."
  type        = string
}
variable "description" {
  description = "Description of the cluster."
  type        = string
  default     = null
}
variable "project" {
  description = "(Optional) The ID of the project in which the resource belongs."
  type        = string
}
variable "location" {
  description = "The location (region or zone) in which the cluster master will be created, as well as the default node location."
  type        = string
  default     = null
}
variable "node_locations" {
  description = "(Optional) The list of zones in which the cluster's nodes are located. "
  type        = list(string)
  default     = null
}
# Structure addons_config
# (Optional) The configuration for addons supported by GKE.
variable "http_load_balancing" {
  description = "(Optional) The status of the HTTP (L7) load balancing controller addon, which makes it easy to set up HTTP load balancers for services in a cluster."
  type = object({
    disabled = bool
  })
  default = null
}
variable "horizontal_pod_autoscaling" {
  description = "(Optional) The status of the Horizontal Pod Autoscaling addon, which increases or decreases the number of replica pods a replication controller has based on the resource usage of the existing pods."
  type = object({
    disabled = bool
  })
  default = null
}
variable "network_policy_config" {
  description = "(Optional) Whether we should enable the network policy addon for the master."
  type = object({
    disabled = bool
  })
  default = null
}
variable "dns_cache_config" {
  description = "(Optional). The status of the NodeLocal DNSCache addon. It is disabled by default."
  type = object({
    enabled = bool
  })
  default = null
}
variable "gcp_filestore_csi_driver_config" {
  description = "(Optional) The status of the Filestore CSI driver addon, which allows the usage of filestore instance as volumes."
  type = object({
    enabled = bool
  })
  default = null
}
variable "cluster_ipv4_cidr" {
  description = "(Optional) The IP address range of the Kubernetes pods in this cluster in CIDR notation (e.g. 10.96.0.0/14)."
  type        = string
  default     = null
}
variable "cluster_autoscaling" {
  description = "(Optional) Per-cluster configuration of Node Auto-Provisioning with Cluster Autoscaler to automatically adjust the size of the cluster and create/delete node pools based on the current needs of the cluster's workload."
  type = object({
    enabled = bool
    resource_limits = optional(list(object({
      resource_type = string
      minimum       = number
      maximum       = number
    })), [])
  })
  default = null
}
variable "default_max_pods_per_node" {
  description = "The maximum number of pods to schedule per node"
  type        = number
  default     = null
}
variable "enable_shielded_nodes" {
  description = "Enable Shielded Nodes features on all nodes in this cluster"
  type        = bool
  default     = null
}
variable "initial_node_count" {
  description = "(Optional) The number of nodes to create in this cluster's default node pool."
  type        = number
  default     = null
}
variable "ip_allocation_policy" {
  description = "(Optional) Configuration of cluster IP allocation for VPC-native clusters."
  type = object({
    cluster_ipv4_cidr_block  = string
    services_ipv4_cidr_block = string
  })
  default = null
}
variable "logging_service" {
  description = "The logging service that the cluster should write logs to. Available options include logging.googleapis.com, logging.googleapis.com/kubernetes (beta), and none"
  type        = string
  default     = null
}
variable "master_authorized_networks_config" {
  description = "The CIDR block where HTTPS access is allowed from"
  type = object({
    cidr_blocks = list(object({
      cidr_block   = string
      display_name = string
    }))
  })
  default = null
}
variable "monitoring_service" {
  description = "The monitoring service that the cluster should write metrics to. Automatically send metrics from pods in the cluster to the Google Cloud Monitoring API. VM metrics will be collected by Google Compute Engine regardless of this setting Available options include monitoring.googleapis.com, monitoring.googleapis.com/kubernetes (beta) and none"
  type        = string
  default     = null
}
variable "network" {
  description = "(Optional) The name or self_link of the Google Compute Engine network to which the cluster is connected."
  type        = string
}
variable "network_policy" {
  description = "(Optional) Configuration options for the NetworkPolicy feature. "
  type = object({
    enabled  = bool
    provider = string
  })
  default = null
}
variable "subnetwork" {
  description = "(Optional) The name or self_link of the Google Compute Engine subnetwork in which the cluster's instances are launched."
  type        = string
}
variable "vertical_pod_autoscaling" {
  description = "Vertical Pod Autoscaling automatically adjusts the resources of pods controlled by it"
  type = object({
    enable = bool
  })
  default = null
}
variable "binary_authorization" {
  description = "Configuration options for the Binary Authorization feature."
  type = object({
    evaluation_mode = string
  })
  default = null
}
variable "private_cluster_config" {
  description = "(Optional) Configuration for private clusters, clusters with private nodes."
  type = object({
    enable_private_endpoint = bool
    enable_private_nodes    = bool
    master_ipv4_cidr_block  = string
  })
  default = null
}
variable "remove_default_node_pool" {
  description = "(Optional) If true, deletes the default node pool upon cluster creation."
  type        = bool
  default     = false
}
variable "workload_metadata_config" {
  description = "(Optional) Metadata configuration to expose to workloads on the node pool."
  type = object({
    mode = string
  })
  default = null
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