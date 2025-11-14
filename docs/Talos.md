# Talos

## Talos image selection

- Use image generator: <https://factory.talos.dev>
- QEMU guest agent
- DRDB, required for LinStore

```yaml
customization:
    systemExtensions:
        officialExtensions:
            - siderolabs/drbd
            - siderolabs/qemu-guest-agent
```

### Manual Talos installation and flux bootstrapping sequence

- Create Talos configuration patch file `patch.yaml`
- Generate configurations: `talosctl gen config cluster05 https://192.168.4.114:6443 --config-patch @patch.yaml`
- `talosctl apply-config --insecure --nodes 192.168.4.114 --file controlplane.yaml`
- `talosctl apply-config --insecure --nodes 192.168.4.115 --file worker.yaml`
- `talosctl bootstrap --nodes 192.168.4.114 --endpoints 192.168.4.114 --talosconfig=./talosconfig`
- `talosctl kubeconfig --nodes 192.168.4.114 --endpoints 192.168.4.114 --talosconfig=./talosconfig`
- `kubectl apply -f cilium.yaml`
- Create Github token, export as GITHUB_TOKEN, with GITHUB_USER
- `flux bootstrap github --context=admin@cluster05 --owner=MoTTTT --repository=venus --branch=main --personal --path=clusters/cluster05 --token-auth=true`

## Useful commands

- Get disk info: `talosctl -n 192.168.4.100,192.168.4.101,192.168.4.103 disks`

### Accessing Logs

- System logs and status logs: `talosctl -n 192.168.4.121 dmesg`, `talosctl -n 192.168.4.121 services`, `talosctl -n 192.168.4.121 logs machined`
- Container list: `talosctl -n 192.168.4.121 containers -k`
- Container logs: `talosctl -n 192.168.4.121 logs -k kube-system/cilium-cxrpb:cilium-agent:904e8a41ccff `
- The "observability" cluster workload includes an installation of Opensearch, and Opensearch Dashboards. The fluentbit can be deployed to any cluster, sending the logs to the Observability cluster.

## Talos patch snippets

A Talos patch set that meets the requirements of the provisioning system, and opinionated CNI and CSI selection, specifically for Cilium and LinStore is configured by default. These choices can be modified in the helm-chart values.yaml file used during provisioning.

To support Proxmox:

- Set Talos machine install disk to default Proxmox boot disk device: `machine.install.disk`

To support Cilium:

- Flannel CNI installs by default. For enterprise CNI features, installing Cilium
- Disable Talos CNI support, in preparation for Cilium installation: `cluster.network.cni.name`, and `cluster.proxy.disabled`
- Load cilium manifest at cluster configuration time (the cluster cannot complete startup without this manifest):`cluster.extraManifests`

Talos specific configurations:

- Configure talos boot image with: `machine.install.image`
- To set a Virtual IP address for the kubernetes api server: `machine.network.interfaces[0].vip.ip`

To support LinStore:

- Distributed Storage: Enable drdb for linstor and piraeus operator: `machine.kernel.modules`

Network environment configurations:

- Internet proxy configuration: `machine.env.http_proxy` and `machine.env.https_proxy`
- For the kubernetes cluster api certificate to be trusted off-net (e.g. via bastion, or routed in from the internet): `cluster.apiServer.certSANs`

Depending on required target cluster workloads:

- For single node clusters: `cluster.allowSchedulingOnControlPlanes`
- Sysctls configuration example: `machine.sysctls.vm.max_map_count`, required for OpenSearch cluster workloads
- Additional manifests to install at cluster startup time (before GitOps bootstrap): `cluster.extraManifests`
- Use `cluster.extraManifests` to install Flux, and a FluxInstance for the target cluster to GitOps bootstrap from.

To support CAPI:

- For CAPI Talos agent install: `cluster.externalCloudProvider`, and configuration: `machine.kubelet.extraArgs`
- For CAPI Talos agent to access kubernetes cluster api: `machine.features.kubernetesTalosAPIAccess`

Machine patch:

```yaml
machine:
  install:
    disk: /dev/vda
    image: {{ .Values.cluster.image }}
  sysctls:
    vm.max_map_count: 262144
  kernel:
    modules:
      - name: drbd
        parameters:
          - usermode_helper=disabled
      - name: drbd_transport_tcp
  kubelet:
    extraArgs:
      rotate-server-certificates: true
      cloud-provider: external
```

Controlplane patch:

```yaml
machine:
 network:
   interfaces:
     - deviceSelector:
         physical: true
       vip:
         ip: {{ .Values.controlplane.endpoint_ip }}
 install:
   disk: /dev/vda
   image: {{ .Values.cluster.image }}
 kernel:
   modules:
     - name: drbd
       parameters:
         - usermode_helper=disabled
     - name: drbd_transport_tcp
 kubelet:
   extraArgs:
     rotate-server-certificates: true
     cloud-provider: external
 features:
   kubernetesTalosAPIAccess:
     enabled: true
     allowedRoles:
       - os:reader
     allowedKubernetesNamespaces:
       - kube-system
 sysctls:
   vm.max_map_count: 262144
cluster:
  apiServer:
    certSANs:
      - {{ .Values.network.bastion_host_endpoint_ip }}
      - {{ .Values.network.bastion_host }}
  network:
    cni:
      name: none
  proxy:
    disabled: true
  {{- with .Values.controlplane.extra_manifests }}
  extraManifests:
  {{- toYaml . | nindent 14 }}
  {{- end }}
  externalCloudProvider:
    enabled: true
    manifests:
      - https://raw.githubusercontent.com/siderolabs/talos-cloud-controller-manager/main/docs/deploy/cloud-controller-manager.yml
```

## Talosctl client configuration notes

- Mac: `brew install siderolabs/tap/talosctl`
- On unix, need to first install brew dependencies: `sudo apt-get install build-essential procps curl file git`
- Then need to install brew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
- Add brew to path: `alias brew="/home/linuxbrew/.linuxbrew/Homebrew/bin/brew"`
- Then talosctl: `brew install siderolabs/tap/talosctl`
- `alias talosctl="/home/linuxbrew/.linuxbrew/Homebrew/Cellar/talosctl/1.9.1/bin/talosctl"`
- Then you can use (or link to): `/home/linuxbrew/.linuxbrew/Cellar/talosctl/1.9.1/bin/talosctl`
- `alias talosctl='/home/linuxbrew/.linuxbrew/Homebrew/Cellar/talosctl/1.9.1/bin/talosctl --talosconfig=/home/colleymj/.talos/talosconfig'`

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

## References

- <https://www.talos.dev/v1.8/introduction/prodnotes/>
- <https://factory.talos.dev/>
- <https://www.talos.dev/v1.8/talos-guides/install/virtualized-platforms/proxmox/>
- <https://www.talos.dev/v1.8/talos-guides/install/cloud-platforms/nocloud/>
- <https://www.civo.com/blog/calico-vs-flannel-vs-cilium>
- <https://cilium.io/>
- <https://github.com/cilium/cilium>
- KaaS GitOps: <https://github.com/kubebn/talos-proxmox-kaas>
- PXE: <https://www.talos.dev/v1.8/talos-guides/install/bare-metal-platforms/pxe/>
- Options: <https://www.civo.com/blog/calico-vs-flannel-vs-cilium>
