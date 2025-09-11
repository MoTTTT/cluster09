# Talos

## Log Visibility

## Talos system level interrogation

- System logs and status logs: `talosctl -n 192.168.4.121 dmesg`, `talosctl -n 192.168.4.121 services`, `talosctl -n 192.168.4.121 logs machined`
- Container list: `talosctl -n 192.168.4.121 containers -k`
- Container logs: `talosctl -n 192.168.4.121 logs -k kube-system/cilium-cxrpb:cilium-agent:904e8a41ccff `

## Aggregating logs

- Using opensearch for search index, and opensearch-dashboard for visibility
- Using fluentbit for log collection

## Generation  2 Configuration

### Backlog

- [ ] Move Loadbalancer manifest to cluster config
- [ ] Log visibility: Send service and kernel logs to fluentbit: Set fluentbit service up as a NodePort
- [ ] Managed secrets: `talosctl gen secrets --from-controlplane-config controlplane.yaml -o secrets.yaml`
- [ ] Observability: tracing with Jaeger
- [ ] Observability / Security: Falco (Security monitoring)
- [ ] Security: Kyverno (Policy as code)
- [ ] Security: Keycloak
- [ ] OpenTelemetry
- [ ] Evaluate TALM: `https://github.com/cozystack/talm`
- [ ] Evaluate authentik
- [ ] Automated provisioning: `https://cozystack.io/`
- [ ] Switch to Gateway API: <https://medium.com/@martin.hodges/why-do-i-need-an-api-gateway-on-a-kubernetes-cluster-c70f15da836c>
- [ ] Split out storage network: `https://cozystack.io/docs/operations/storage/dedicated-network/`
- [ ] Refactor ingresses with URL prefixes
- [ ] Security SSO: Oauth2-proxy
- [ ] SOPS with age <https://fluxcd.io/flux/guides/mozilla-sops/#encrypting-secrets-using-age>; <https://pkg.go.dev/filippo.io/age>
- [ ] Investigate kubewall <https://github.com/kubewall/kubewall>
- [ ] Investigate Kubeshark: Network traffic analyser <https://github.com/kubeshark/kubeshark>
- [ ] Investigate Pixie <https://px.dev/>
- [ ] Investigate Jaeger <https://github.com/jaegertracing/jaeger-operator>
- [ ] Investigate OpenTelemetry: <https://opentelemetry.io/>; <https://github.com/open-telemetry/opentelemetry-operator>
- [ ] Investigate Kubeflow (AI Tool ecosystem): <https://www.kubeflow.org/>
- [ ] Investigate: For VMs in k8s, see kubevirt
- [ ] Investigate: For flux git access secret <https://fluxcd.io/flux/cmd/flux_create_secret_git/>

### Cluster08 changes

- [X] Template for `clusterctl generate cluster`: `clusterctl generate yaml  --from cluster-template.yaml > cluster08.yaml`
- [ ] Gateway API for Hubble: <https://blog.grosdouli.dev/blog/cilium-gateway-api-cert-manager-let's-encrypt>

### Cluster07 changes

- [X] Cluster API: clusterctl for provisioning (cluster api operator rolled back)
- [X] Final talos config {VIP, mirror registry (harbor), drbd, sysctls, certSANs, cilium, talos-cloud-controller-manager}
- [X] Move extraManifests to local httpd {kubelet-serving-cert-approver, metrics-server, piraeus-operator, gateway-api, cilium}
- [X] Reintroduce support for cilium, drdb
- [ ] Fix mv naming (what was this?)

### Cluster06 changes

- [X] Switch to Cluster API for provisioning, with simplified talos config

### Cluster05 changes

- [X] Use TALM for talos configuration: Cancelled
- [X] Reduce disk to 40 GB: Reduce storage startup time?: {8 CPU; 16 GB RAM; 40 GB Disk}

### Cluster04 changes

- [X] Dependency: Harbor
- [X] Configure machine.registry (Harbour) as docker caching repository
- [X] Workload: Prometheus and Grafana
- [X] Cache Talos startup image on bastion server: `https://factory.talos.dev/image/ed7716909fb764e0c322ab43dd20918e30cf8ffa3914ba3fa229afec9efe4d84/v1.10.2/nocloud-amd64.iso`
- [X] Helm chart dependsOn: Fix for dashboards index creation failure
- [X] Split Opensearch roles
- [X] Distribute ingresses
- [X] Add worker node
- [X] Workload: Keycloak

### Cluster03 Changes

- [X] Workload: Radio station (ingress, nfs, storageclass)
- [X] Dependency: NFS
- [X] Add log visibility: Machine definition pre-requisites
- [X] Increase boot size to accommodate linstore pool usage
- [X] VM dimensions {8 CPU; 16 GB RAM; 80 GB Disk}

### Cluster02 Changes

- [X] Workload: OpenSearch with Dashboard
- [X] Workload: fluentbit {collect logs from kubernetes containers}
- [X] Move affinity controller installation to after linstor is stable
- [X] Fix: Shared ingress
- [X] Adjust resource allocations
- [X] Abstraction of controlplane and worker resource dimensions
- [X] Abstraction of Talos version
- [X] Kustomization patch for Ingres load balancer IP Pool
- [X] Support for internet proxy:
- [X] VM dimensions {8 CPU; 16 GB RAM; 40 GB Disk}

## Generation 01

- VM dimensions {4 CPU; 8 GB RAM; 20 GB Disk

## Cluster08

Using CreateVMDefinitions.sh process template files to:

- Generate terraform vm definitions, provider definition, and talos installation media
- Generate Cilium manifests and appends them to talos patch file
- Generate createCluster.sh, which generates (patched) talos configs and apply then to the machines in the cluster
- createCluster.sh also generates command snippets for talos bootstrap, kube config, flux bootstrap, dashboard access etc

VM dimensions

- 4 CPU
- 8 GB RAM
- 20 GB Disk

### Cluster05

- `talosctl gen config cluster05 https://192.168.4.114:6443 --config-patch @patch.yaml`
- `talosctl apply-config --insecure --nodes 192.168.4.114 --file controlplane.yaml`
- `talosctl apply-config --insecure --nodes 192.168.4.115 --file worker.yaml`
- `talosctl bootstrap --nodes 192.168.4.114 --endpoints 192.168.4.114 --talosconfig=./talosconfig`
- `talosctl kubeconfig --nodes 192.168.4.114 --endpoints 192.168.4.114 --talosconfig=./talosconfig`
- `kubectl apply -f cilium.yaml`
- `kubectl apply --server-side -k "https://github.com/piraeusdatastore/piraeus-operator/config/default?ref=v2.8.1"`
- Create Github token, export as GITHUB_TOKEN, with GITHUB_USER
- `flux bootstrap github --context=admin@cluster05 --owner=MoTTTT --repository=venus --branch=main --personal --path=clusters/cluster05 --token-auth=true`

To create flux resource for piraeus:

flux create source git piraeus --url=https://github.com/piraeusdatastore/piraeus-operator/config/default --tag="v2.8.1"


### Cluster03

Using patches, with talos image supporting:

- QEMU guest agent
- DRDB, required for LinStore

```yaml
customization:
    systemExtensions:
        officialExtensions:
            - siderolabs/drbd
            - siderolabs/qemu-guest-agent
```

- `talosctl gen config cluster03 https://192.168.4.216:6443 --config-patch @patch.yaml`
- `talosctl apply-config --insecure --nodes 192.168.4.216 --file controlplane.yaml`

```yaml
machine:
  install:
    disk: /dev/vda
    image: ?????
  kernel:
    modules:
      - name: drbd
        parameters:
          - usermode_helper=disabled
      - name: drbd_transport_tcp
  env:
    https_proxy: http://192.168.4.1:3128/
cluster:
  network:
    cni:
      name: none
  proxy:
    disabled: true
  allowSchedulingOnControlPlanes: true
```

### Cluster02

Manually editing controlplane.yaml and worker.yaml files.

- Generate cluster config: `talosctl gen config cluster02 https://192.168.4.210:6443`
- Check the storage device to use: `talosctl -n 192.168.4.210 disks --insecure`
- Edit controlplane.yaml and worker.yaml files. Set IP address and storage devices.
- `talosctl apply-config --insecure --nodes 192.168.4.210 --file controlplane.yaml`
- `talosctl apply-config --insecure --nodes 192.168.4.211 --file worker.yaml`
- `talosctl --talosconfig=./talosconfig --nodes 192.168.4.211 -e 192.168.4.210 version`
- `talosctl bootstrap --nodes 192.168.4.210 --endpoints 192.168.4.210 --talosconfig=./talosconfig`
- `talosctl kubeconfig --nodes 192.168.4.210 --endpoints 192.168.4.210 --talosconfig=./talosconfig`
- `talosctl --nodes 192.168.4.210 --endpoints 192.168.4.210 health --talosconfig=./talosconfig`
- `talosctl --nodes 192.168.4.211 --endpoints 192.168.4.210 dashboard --talosconfig=./talosconfig`

### Generation 0: Configuration on Mars

- ProxMox: Load image into local-lvm: <https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.8.2/nocloud-amd64.iso>
- Proxmox: Create VMs, with 4 CPU, 16 GB RAM, and 100 GB Disk, using talos nocloud-amd64.iso
- ProxMox: Add CloudInit drive, and set IP addresses *{192.168.4.100,192.168.4.101,192.168.4.103}*
- Generate cluster config: `talosctl gen config mars01 https://192.168.4.100:6443 --output-dir mars01`
- Modify generated `controlplane.yaml` file, and place in /var/lib/vz/snippets/controlplane.yaml (ensure that local-lvm supports snippets)
- Control plane: add config to CloudInit drive: `qm set $VMID --cicustom user=local:snippets/controlplane.yaml`
- Worker: config to CloudInit drive: `qm set $VMID --cicustom user=local:snippets/worker.yaml`
- Bootstrap cluster: `talosctl bootstrap -n 192.168.4.100`
- Get kubectl config: `talosctl kubeconfig -n 192.168.4.100 --endpoints 192.168.4.100`
- Create git repo *Mars*, token with admin privileges, export as GITHUB_TOKEN, with GITHUB_USER
- Bootstrap gitops: `flux bootstrap github --context=admin@mars01 --owner=MoTTTT --repository=mars --branch=main --personal --path=clusters/mars01 --token-auth=true`
- Add supporting infrastructure manifests in Mars repo: MetalLB; ingres-nginx; cert-manager;
- Add application manifests in Mars repo
- Get disk info: `talosctl -n 192.168.4.100,192.168.4.101,192.168.4.103 disks`

### controlplane.yaml deviations

- cilium

```yaml
cluster:
  network:
    cni:
      name: none
  proxy:
    disabled: true
  allowSchedulingOnControlPlanes: true
```

- proxy

```yaml
machine:
    env:
        https_proxy: http://192.168.3.1:3128/
```

talosctl gen config talos-nocloud https://192.168.30:6443 --config-patch @patch.yaml

## Lab environments

- Server: Mars with 32 CPU; 220 GB RAM; 2 X 1TB, 4 X 600GB Disk
- Server: Mercury with 32 CPU; 220 GB RAM; 2 X 1TB, 4 X 600GB Disk
- Server: Venus: Proxmox on R730 with 64 CPUs; 160GB RAM; 1.6 TB zfs pool

## Talosctl client configuration

- Mac: `brew install siderolabs/tap/talosctl`
- On unix, need to first install brew dependencies: `sudo apt-get install build-essential procps curl file git`
- Then need to install brew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- Add brew to path: `alias brew="/home/linuxbrew/.linuxbrew/Homebrew/bin/brew"`
- Then talosctl: `brew install siderolabs/tap/talosctl`
- `alias talosctl="/home/linuxbrew/.linuxbrew/Homebrew/Cellar/talosctl/1.9.1/bin/talosctl"`
- Then you can use (or link to): `/home/linuxbrew/.linuxbrew/Cellar/talosctl/1.9.1/bin/talosctl`
- `alias talosctl='/home/linuxbrew/.linuxbrew/Homebrew/Cellar/talosctl/1.9.1/bin/talosctl --talosconfig=/home/colleymj/.talos/talosconfig'`

## Networking

- Flannel installs by default
- For enterprise CNI features, installing Cilium
- PXE Boot:

Use PXE for boot, with metadata service for per machine (MAC Address) configuration.

```bash
talos.config=https://metadata.service/talos/config?mac=${mac}
```

## Talos internet proxy support

For initial boot, add command line arguments: `talos.environment=http_proxy=http://192.168.4.51:3128 talos.environment=https_proxy=http://192.168.4.51:3128`

Talos image factory specification, supporting drbd fir linode (existing), qemu-guest-agent for terraform remote control (existing), and a new squid proxy, on the cluster hardware.

```yaml
customization:
    extraKernelArgs:
        - talos.environment=http_proxy=http://192.168.4.51:3128
        - talos.environment=https_proxy=http://192.168.4.51:3128
    systemExtensions:
        officialExtensions:
            - siderolabs/drbd
            - siderolabs/qemu-guest-agent
```

For runtime, add machine configuration to the patch:

```yaml
machine:
  env:
    http_proxy: http://192.168.4.51:3128
    https_proxy: http://192.168.4.51:3128
    no_proxy: "localhost,127.0.0.1,192.168.4/24,10.244.0.0/16,10.96.0.0/12"
```

## Serving manifests and images locally

- Apache set up on a VM: <http://192.168.4.5/>

Supported manifests:

- kubelet-serving-cert-approver.yaml
- metrics-server.yaml
- piraeus-operator.yaml
- gateway-api.yaml
- cilium.yaml

Supported images:

- <https://factory.talos.dev/image/TALOSIMAGEID/${local.talos.version}/nocloud-amd64.iso>
- TALOSIMAGEID: `ed7716909fb764e0c322ab43dd20918e30cf8ffa3914ba3fa229afec9efe4d84`
- Talos version: `v1.10.2`
- <http://192.168.4.5/nocloud-amd64.iso>

## Cluster components

- <https://github.com/adampetrovic/home-ops/tree/main>
- <https://www.cloudraft.io/blog/making-kubernetes-simple-with-talos>
- <https://blog.devops.dev/talos-os-raspberry-fc5f327b7026>
- <https://kevinholditch.co.uk/2023/10/21/creating-a-kubernetes-cluster-using-talos-linux-on-xen-orchestra/>

## References

- <https://www.talos.dev/v1.8/introduction/prodnotes/>
- <https://factory.talos.dev/?arch=amd64&cmdline-set=true&extensions=-&extensions=siderolabs%2Fiscsi-tools&extensions=siderolabs%2Fqemu-guest-agent&platform=nocloud&target=cloud&version=1.8.2>
- <https://www.talos.dev/v1.8/talos-guides/install/virtualized-platforms/proxmox/>
- <https://www.talos.dev/v1.8/talos-guides/install/cloud-platforms/nocloud/>
- <https://blog.devops.dev/talos-os-raspberry-fc5f327b7026>
- <https://www.civo.com/blog/calico-vs-flannel-vs-cilium>
- <https://cilium.io/>
- <https://www.cloudraft.io/blog/making-kubernetes-simple-with-talos>
- <https://github.com/adampetrovic/home-ops/blob/main/kubernetes/bootstrap/talos/talconfig.yaml>
- KaaS GitOps: <https://github.com/kubebn/talos-proxmox-kaas>
- PXE: <https://www.talos.dev/v1.8/talos-guides/install/bare-metal-platforms/pxe/>
- Options: <https://www.civo.com/blog/calico-vs-flannel-vs-cilium>
- <https://github.com/cilium/cilium>
- <https://github.com/cilium/cilium/blob/v1.18.1/install/kubernetes/cilium/values.yaml#L992>