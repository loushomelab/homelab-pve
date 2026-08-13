# Talos Cluster Provisioning

This directory contains the Terraform configuration for configuring the Talos Linux cluster.

## Getting Cluster Configurations (talosconfig & kubeconfig)

After successfully running `terraform apply`, Terraform will generate and store the cluster credentials in its state. You can extract them to your local machine to interact with the cluster using `talosctl` and `kubectl`.

Run the following commands in this directory to export the configurations:

```bash
# 1. Export talosconfig to your default Talos configuration directory
terraform output -raw talosconfig > ~/.talos/config

# 2. Export kubeconfig to your default Kubernetes configuration directory
terraform output -raw kubeconfig > ~/.kube/config
```

### Verification

To verify that your Talos CLI is correctly configured and can communicate with the cluster, run:
```bash
talosctl config info
talosctl -n 192.168.50.110 version
```

To verify Kubernetes access (Note: it may take a few minutes for the Kubernetes API server to become fully ready after a fresh bootstrap):
```bash
kubectl get nodes
```
