output "talosconfig" {
  description = "Talos client configuration (talosconfig)"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubernetes client configuration (kubeconfig)"
  value = yamlencode(merge(
    yamldecode(resource.talos_cluster_kubeconfig.this.kubeconfig_raw),
    {
      contexts = [
        for ctx in yamldecode(resource.talos_cluster_kubeconfig.this.kubeconfig_raw).contexts : merge(ctx, {
          context = merge(ctx.context, { namespace = "argocd" })
        })
      ]
    }
  ))
  sensitive = true
}
