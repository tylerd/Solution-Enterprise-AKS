output "client_certificate" {
  value = var.create_cluster ? azurerm_kubernetes_cluster.main.0.kube_config.0.client_certificate : ""
}

output "kube_config" {
  value = var.create_cluster ? azurerm_kubernetes_cluster.main.0.kube_config_raw : ""
}