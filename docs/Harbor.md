# Harbor Installation

## Container image caching

Over 6 GB of in container images are pulled regularly pulled by each kubernetes node, even for a cluster with a small workload. Many of these containers are identical between cluster nodes, but are typically each pulled individually from public image repositories.

If clusters are regularly destroyed and rebuilt, together with their workload, as is required in a platform lab, image pull duration becomes the largest factor in cluster provisioning time. Rate limiting on public repositories also becomes a factor.

Including a cluster caching repository on the cluster would significantly reduce per cluster provisioning time.

Including a caching repository at an infrastructure level would reduce cluster provisioning time further, and would provide the best mitigation against rate limiting on public repositories.

Harbor is used here to achieve caching, improving cluster provisioning time, and avoiding rate limiting risks.

Harbor will be installed in a dedicated VM in the Proxmox cluster.

On a proxmox host:

- Download no-cloud ubuntu image: <wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img>
- Create a VM with VM ID 1000 with no OS and Hard Disk config, without starting it.
- Import the image into the VM: `qm importdisk 1000 noble-server-cloudimg-amd64.img pool1` (pool1 may be local or local-lvm etc)
- Add a cloudinit drive to the VM, and set up access controls and IP address. In this case we use `192.168.4.100`
- Configure boot order, resize the VM hard drive to accommodate image cache. In this case we use 55 GB.
- Start the VM, log in and install docker <https://docs.docker.com/engine/install/ubuntu/>.
- Install harbor with quick install script <https://goharbor.io/docs/2.0.0/install-config/quick-install-script/>
- Configure at least `gcr.io`, `registry.k8s.io`, `ghrc.io`, and `hub.docker.com` Registries, and proxied Projects for each.
- In the cluster09 workload, there are images from the following that can also be proxied: `quay.io`, `cr.fluentbit.io`.
- Add `machine.registries.mirrors` entries to tolos configurations, in the following form, for each Project created:

```yaml
machine:
  registries:
    mirrors:
      docker.io:
        endpoints:
          - http://192.168.4.100/v2/proxy-docker.io
        overridePath: true
```

- Add `machine.registries.config` entry for the credentials set up for harbor. By default this will be:

```yaml
machine:
  registries:
    config:
      192.168.4.100:
        auth:
          username: admin
          password: Harbor12345
```

## References

- <https://docs.siderolabs.com/talos/v1.10/configure-your-talos-cluster/images-container-runtime/pull-through-cache>
