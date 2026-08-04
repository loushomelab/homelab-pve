# ==============================================================================
# ☸️ Kubernetes Provider
# ==============================================================================
provider "kubernetes" {
  # HCP Terraform 本地代理或你本地执行时读取的 Kubeconfig
  config_path = "~/.kube/config"
}

# ==============================================================================
# 🔐 Secrets via Doppler (Operator Token)
# ==============================================================================
data "doppler_secrets" "operator" {
  config  = "prd_terraform"
  project = "k8s"
}

resource "kubernetes_namespace" "doppler" {
  metadata {
    name = "doppler-operator-system"
  }
}

resource "kubernetes_secret" "doppler_token" {
  metadata {
    name      = "doppler-operator-token"
    namespace = kubernetes_namespace.doppler.metadata[0].name
  }
  data = {
    dopplerToken = data.doppler_secrets.operator.map.K8S_OPERATOR_DOPPLER_TOKEN
  }
  type = "Opaque"
}
