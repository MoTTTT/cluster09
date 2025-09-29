# Cluster API

## clusterctl

- Tested successfully with 2 node talos cluster (Aug 2025)
- Install cert-manager: `helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true`
- Set up clusterctl config file: `~/.cluster-api/clusterctl.yaml` (On initial install only CAPI mandatory fields are set)
- Install components: `clusterctl init --ipam in-cluster --core cluster-api -c talos -b talos -i proxmox`
- Version installed, based on init response:

```bash
Installing provider="cluster-api" version="v1.10.5" targetNamespace="capi-system"
Installing provider="bootstrap-talos" version="v0.6.9" targetNamespace="cabpt-system"
Installing provider="control-plane-talos" version="v0.5.10" targetNamespace="cacppt-system"
Installing provider="infrastructure-proxmox" version="v0.7.3" targetNamespace="capmox-system"
Installing provider="ipam-in-cluster" version="v1.0.3" targetNamespace="capi-ipam-in-cluster-system"
```

clusterctl generate yaml --list-variables --from cluster-template.yaml > cluster08-variables.yaml
clusterctl generate yaml --from cluster-template.yaml > cluster08.yaml 


- Spin up a cluster: `kubectl apply -f proxmoxcluster.yaml`
- Describe cluster: `clusterctl describe cluster cluster07 -n cluster07 --show-conditions all --show-templates --show-resourcesets --grouping=false --echo`
- Retrieve talos config: `kubectl get secret --namespace cluster07 cluster07-talosconfig -o jsonpath='{.data.talosconfig}' | base64 -d > cluster07-talosconfig`
- Retrieve kubeconfig: `talosctl kubeconfig --nodes 192.168.4.170 --endpoints 192.168.4.170 --talosconfig=./cluster07-talosconfig`
- To retrieve file: `kubectl get secret --namespace cluster07 cluster07-kubeconfig -o jsonpath='{.data.value}' | base64 -d > cluster07-kubeconfig`
- scale up cluster control plane: Change replicas to 3
- scale up workers: Change replicas to 2
- bootstrap flux: `flux bootstrap github --context=admin@cluster07 --owner=MoTTTT --repository=venus --branch=main --personal --path=clusters/managedcluster07 --token-auth=true`

## Cluster API Operator

- Install cert-manager: `helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true`
- Install CAPI Operator: `helm install capi-operator capi-operator/cluster-api-operator --create-namespace -n capi-operator-system --set infrastructure.proxmox.enabled=true --set controlPlane.talos.enabled=true --set  bootstrap.talos.enabled=true --wait --timeout 90s`
- Configure proxmox credentials: `kubectl apply -f capmox-manager-credentials.yml`
- `helm repo add capi-operator https://kubernetes-sigs.github.io/cluster-api-operator`
- `helm install capi-operator capi-operator/cluster-api-operator --create-namespace -n capi-operator-system --set infrastructure.proxmox.enabled=true --set configSecret.name=capmox-manager-credentials --set configSecret.namespace=default --set controlPlane.talos.enabled=true --set  bootstrap.talos.enabled=true --wait --timeout 90s`

## Issues and notes

- Setting IP addresses using cloudinit: `You will need to make sure that your VM template doesn't have Cloud-init Driver provided by Proxmox, otherwise, that will overwrite the config of CAPMOX. No need to pre-set up the Cloud-init Drive.Just use an empty CD ROM at ide0, and CAPMOX will do the job.`
- `clusterctl generate cluster` does not have an option to specify control-plane or bootstrap providers, and assumes cubeadm for both.
- clusterctl init creates a secret called `capmox-manager-credentials` in the `capmox-system` namespace.
- cluster operator creates this in the `proxmox-infrastructure-system namespace` (with empty values).
- Loading a secret manifest sets the values. Loading a cluster manifest resets them to their defaults (to be confirmed...)
- In cluster operator scenario, Proxmox expects ProxmoxCluster to include a spec.credentialsRef.
- `clusterctl generate cluster` does not include spec.credentialsRef in the generated ProxmoxCluster manifest.
- The above discrepancies could relate to version differences.
- Generate cluster manifest: `clusterctl generate cluster cluster07 --kubernetes-version v1.31.2 --control-plane-machine-count=1 --infrastructure=proxmox:v0.7.3 > cluster07.yaml`
- NOTE: This is not useful for talos controlplane an bootstrap unless a custom template is used.
- For cluster management investigate headlamp, <https://github.com/Jont828/cluster-api-visualizer/tree/main>

## References

- <https://cluster-api.sigs.k8s.io/user/quick-start>
- <https://github.com/k8s-proxmox/cluster-api-provider-proxmox>
- <https://github.com/siderolabs/cluster-api-bootstrap-provider-talos>
- <https://github.com/siderolabs/cluster-api-control-plane-provider-talos>
- Discussion on flux with Cluster API Operator: <https://github.com/ionos-cloud/cluster-api-provider-proxmox/issues/221>
- Flux repo example: <https://github.com/a7d-corp/homelab-clusters-fleet/tree/main>