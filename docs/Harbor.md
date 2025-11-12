# Harbor Installation

## Container image caching

Over 6 GB of in container images are pulled regularly pulled by each kubernetes node, even for a cluster with a small workload. Many of these containers are identical between cluster nodes, but are typically each pulled individually from public image repositories.

If clusters are regularly destroyed and rebuilt, together with their workload, as is required in a platform lab, image pull duration becomes the largest factor in cluster provisioning time. Rate limiting on public repositories also becomes a factor.

Including a cluster caching repository on the cluster would significantly reduce per cluster provisioning time. Including a caching repository at an infrastructure level would reduce cluster provisioning time further, and would provide the best mitigation against rate limiting on public repositories.

Harbor is used here to achieve caching, improving cluster provisioning time, and avoiding rate limiting risks.

Harbor will be installed in a dedicated VM in the Proxmox cluster.

- Download no-cloud ubuntu image: <wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img>

## References

- <https://docs.siderolabs.com/talos/v1.10/configure-your-talos-cluster/images-container-runtime/pull-through-cache>
