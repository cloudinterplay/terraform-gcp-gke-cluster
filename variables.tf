# Each resource variable has prefix which indicate the resource it's related to.
# For example cluster{{ some variable}}, means variable for google_container_cluster

# Variables related to cluster it-self
# google_container_cluster.name
variable "cluster_name" {
  type = string
}
# google_container_cluster.location
variable "cluster_location" {
  type = string
}
# google_container_cluster.initial_node_count
variable "cluster_initial_node_count" {
  type = string
}
# google_container_cluster.ip_allocation_policy
variable "cluster_ip_allocation_policy" {
  type = object({
    cluster_ipv4_cidr_block  = string
    services_ipv4_cidr_block = string
  })
}
# google_container_cluster.network
variable "cluster_network" {
  type = string
}
# google_container_cluster.subnetwork
variable "cluster_subnetwork" {
  type = string
}
# google_container_cluster.master_authorized_networks_config
variable "cluster_master_authorized_networks_config" {
  description = "The CIDR block where HTTPS access is allowed from"
  type = object({
    cidr_blocks = list(object({
      cidr_block   = string
      display_name = string
    }))
  })
  default = null
}
# google_container_cluster.private_cluster_config
variable "cluster_private_cluster_config" {
  type = object({
    enable_private_endpoint = bool
    enable_private_nodes    = bool
    master_ipv4_cidr_block  = string
  })
}
# google_container_cluster.node_config
variable "cluster_node_config" {
  type = object({
    disk_size_gb = string
    disk_type    = string
    machine_type = string
    spot         = bool
  })
}
# google_container_cluster.remove_default_node_pool
variable "cluster_remove_default_node_pool" {
  type    = bool
  default = false
}
