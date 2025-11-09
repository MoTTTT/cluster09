# Planning

## Backlog

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

### Cluster09 changes

- [X] Greenfields Bootstrap {Terraform templates and Talos config, and documents for Management Cluster}
- [X] Manual CAPI provider installation
- [X] Manual Management cluster gitops bootstrap
- [ ] Managed cluster dependencies served by Management cluster workload
- [ ] Cluster dependency: Image cache
- [ ] Cluster dependency: Manifest server
- [ ] Cluster dependency: Documentation

### Cluster08 changes

- [X] Template for `clusterctl generate cluster`: `clusterctl generate yaml  --from cluster-template.yaml > cluster08.yaml`
- [X] Gateway API for Hubble: <https://blog.grosdouli.dev/blog/cilium-gateway-api-cert-manager-let's-encrypt>

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

## Generation 01: Cluster08

Using CreateVMDefinitions.sh process template files to:

- Generate terraform vm definitions, provider definition, and talos installation media
- Generate Cilium manifests and appends them to talos patch file
- Generate createCluster.sh, which generates (patched) talos configs and apply then to the machines in the cluster
- createCluster.sh also generates command snippets for talos bootstrap, kube config, flux bootstrap, dashboard access etc

### Generation 01: Cluster05

- `talosctl gen config cluster05 https://192.168.4.114:6443 --config-patch @patch.yaml`
- `talosctl apply-config --insecure --nodes 192.168.4.114 --file controlplane.yaml`
- `talosctl apply-config --insecure --nodes 192.168.4.115 --file worker.yaml`
- `talosctl bootstrap --nodes 192.168.4.114 --endpoints 192.168.4.114 --talosconfig=./talosconfig`
- `talosctl kubeconfig --nodes 192.168.4.114 --endpoints 192.168.4.114 --talosconfig=./talosconfig`
- `kubectl apply -f cilium.yaml`
- `kubectl apply --server-side -k "https://github.com/piraeusdatastore/piraeus-operator/config/default?ref=v2.8.1"`
- Create Github token, export as GITHUB_TOKEN, with GITHUB_USER
- `flux bootstrap github --context=admin@cluster05 --owner=MoTTTT --repository=venus --branch=main --personal --path=clusters/cluster05 --token-auth=true`
- To create flux resource for piraeus: `flux create source git piraeus --url=https://github.com/piraeusdatastore/piraeus-operator/config/default --tag="v2.8.1"`
