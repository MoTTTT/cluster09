# Cluster-Chart

Cluster-Chart is a helm chart for provisioning Talos kubernetes clusters on a Proxmox Hypervisor using Cluster API.

Chart templates can be found in the cluster-chart directory.

To publish the chart to a cloned repo:

- Create a chart binary file by running the following in the repo root directory: `helm package cluster-chart`
- Create, or update the chart repo manifest: `helm repo index .`
