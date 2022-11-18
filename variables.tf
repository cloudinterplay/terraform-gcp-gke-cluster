variable "project_id" {
  type        = string
  description = "The project ID to host the network in"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "region" {
  type        = string
  description = "The region to use"
}

variable "node_zones" {
  type        = list(string)
  description = "The zones where worker nodes are located"
}

variable "node_pool" {
  type        = object({
    autoscaling = object({
      max_node_count = number
      min_node_count = number
    })
    node_config = object({
      preemptible = bool
      machine_type = string
      image_type   = string
      disk_size_gb = number
    })
  })
  default = {
    autoscaling = {
      max_node_count = 2
      min_node_count = 1
    }
    node_config = {
      preemptible = true
      machine_type = "e2-medium"
      image_type   = "ubuntu_containerd"
      disk_size_gb = 10
    }
  }
  description = "Node pool configuration"
}

variable "network" {
  type        = string
  description = "The name of the app VPC"
}

variable "subnetwork" {
  type        = string
  description = "The name of the app subnet"
}

variable "service_account" {
  type        = string
  description = "The service account to use"
}

variable "cluster_ipv4_cidr_block" {
  type        = string
  description = "The CIDR block to use for pod IPs"
}

variable "services_ipv4_cidr_block" {
  type        = string
  description = "The CIDR block to use for the service IPs"
}

variable "authorized_ipv4_cidr_block" {
  type        = string
  description = "The CIDR block where HTTPS access is allowed from"
  default     = null
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "The /28 CIDR block to use for the master IPs"
}