# cluster09

Scripts, templates, manifests and documentation for a the provisioning of a Cluster API management cluster, with templated cluster manifest generation.

## Target deployment environment, and technology selection

- Proxmox hypervisor
- Talos OS and Kubernetes distribution
- Cluster API for cluster management
- Flux for GitOps cluster deployments, and cluster workload deployments

## Quick start

### Management cluster

- Pull repo
- Configure management cluster dimensioning, IP Address assignments, and hypervisor connectivity
- Generate management cluster scripts and manifests
- Initialise and execute terraform VM creation
- Configure talos VMs
- Bootstrap Talos cluster
- Extract talosctl and kubectl configurations
- Flux bootstrap Management cluster
- GitOps: Deploy infrastructure components to Management cluster
- GitOps: Deploy and configure harvest

### Workload cluster

- Configure new cluster in clusterctl config
- Generate Workload cluster manifest from Cluster template
- Check into GitOps repo
- Extract talosctl and kubectl configurations
- Flux bootstrap Workload cluster
- GitOps: Deploy infrastructure components to Workload cluster
- GitOps: Deploy and configure workload components to Workload cluster

## Extracting talosctl and kubectl configurations

- Given a workload cluster **observability**.
- Retrieve Talos config file: `kubectl get secret --namespace observability observability-talosconfig -o jsonpath='{.data.talosconfig}' | base64 -d > observability-talosconfig.yaml`
- Retrieve Kubeconfig file: `kubectl get secret --namespace observability observability-kubeconfig -o jsonpath='{.data.value}' | base64 -d > observability-kubeconfig.yaml`
- Set .kube config: `talosctl kubeconfig --nodes 192.168.4.100 --endpoints 192.168.4.100 --talosconfig=./observability-talosconfig.yaml`

## Flux bootstrap

- Export GitHub username `export GITHUB_USER=github_username`
- Set up GitHub token: `export GITHUB_TOKEN=github_pat_XXXX`
- Bootstrap Flux: `flux bootstrap github --context=admin@observability --owner=MoTTTT --repository=cluster09 --branch=main --personal --path=clusters/observability --token-auth=true`
