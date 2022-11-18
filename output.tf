output "name" {
  value       = google_container_cluster.app_cluster.name
  description = "The Kubernetes cluster name."
}

output "endpoint" {
  value       = google_container_cluster.app_cluster.endpoint
  description = "The Kubernetes endpoint."
}

output "master_auth" {
  value       = google_container_cluster.app_cluster.master_auth
  description = "The Kubernetes master_auth."
}

output "service_account" {
  value       = google_service_account.default.email
  description = "The Service account associated with Kubernetes cluster."
}