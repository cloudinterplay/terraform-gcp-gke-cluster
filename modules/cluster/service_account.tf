resource "random_string" "cluster_service_account_suffix" {
  upper   = false
  lower   = true
  special = false
  length  = 4
}
resource "google_service_account" "cluster_service_account" {
  project      = var.project
  account_id   = "tf-gke-${substr(var.name, 0, min(15, length(var.name)))}-${random_string.cluster_service_account_suffix.result}"
  display_name = "Terraform-managed service account for cluster ${var.name}"
}