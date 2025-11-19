# Adding Clusters

Once the Management cluster is provisioning a cluster supported by existing gitops examples, such as the observability stack, new managed clusters can be added to the gitops repo using the following process, which could be automated:

GitOps repo:

- Clone an existing cluster specification, e.g.  /cluster/observablity to create /clusters/<cluster name>
- Edit /clusters/<cluster name>/flux-system/gotk-sync.yaml with the correct repo and path.
- Clone /gitops/gitops-gateway/observability to create /gitops/gitops-gateway/<cluster name>
- Rename /gitops/gitops-gateway/<cluster name>/observability-gateway.yaml to /gitops/gitops-gateway/<cluster name>/<cluster name>-gateway.yaml
- Edit /gitops/gitops-gateway/<cluster name>/<cluster name>-gateway.yaml to configure domains supported by the cluster
- Clone /gitops/cluster-charts/observability to create /gitops/cluster-charts/<cluster name>
- Rename /gitops/cluster-charts/observability/observability.yaml to /gitops/cluster-charts/<cluster name>/<cluster name>.yaml
- Review the configuration of the files in /gitops/cluster-charts/<cluster name>/ configuring cluster dimensions and networking as required.
- Add an entry into /cluster/management/clusters.yaml

## Automation

- Create a set of templates (kustomizations, values files, manifests etc), with tokens for the configuration items.
- Examine ways to move configuration into the helm chart.
- Automate deployment of local manifests
