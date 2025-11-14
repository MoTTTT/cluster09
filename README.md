# cluster09

Scripts, templates, manifests and documentation for a the provisioning of a Cluster API management cluster, with templated cluster manifest generation.

## URLs

- GitHub pages README.md: <https://motttt.github.io/cluster09/>
- Chart index file: <https://motttt.github.io/cluster09/index.yaml>
- Documentation site deployed in GitHub: <https://motttt.github.io/cluster09/site/>
- Documentation site deployed to cluster09: <https://cluster09-docs.podzone.cloud/>
- Manifest directory: <https://motttt.github.io/cluster09/manifests/>
- Sample Cluster FluxInstance: <https://motttt.github.io/cluster09/cluster-manifests/flux-instance-observability.yaml>

## Target deployment environment, and technology selection

- Proxmox hypervisor
- Talos OS and Kubernetes distribution
- Cluster API for cluster management
- Flux for GitOps cluster deployments, and cluster workload deployments

## Quick start

### Management cluster

- Pull repo
- Configure management cluster dimensioning, IP Address assignments, and hypervisor connectivity: `cluster-bootstrap` directory, `createVMDefinition.sh` file.
- Generate management cluster scripts and manifests: `chmod +x createVMDefinition.sh && ./createVMDefinition.sh`
- Initialise and execute terraform VM creation. `cd vms && terraform init && terraform apply -parallelism=1`
- Configure talos VMs: `cd ../talos && ./createCluster.sh`; Instructions will be printed to guide you through the following:
- Bootstrap Talos cluster.
- Extract talosctl and kubectl configurations
- Flux bootstrap Management cluster
- GitOps: Deploy infrastructure components to Management cluster
- GitOps: See `/clusters/` directory for "flux kustomizations", and 
- GitOps: See `/gitops/gitops-infra/` for manifests and "kustomize kustomizations".

### Workload cluster

- GitOps: Add new workload cluster kustomization: See `/clusters/cluster09` directory for a sample, using default values. `/clusters/observability` is a sample with a more complex cluster load.
- GitOps: Configure helm chart values file for new cluster kustomization
- GitOps: Commit changes to GitOps repo, to deploy new target cluster.
- Monitor the cluster deployment in the hypervisor, and on the management cluster.
- Describe the helm chart on the Management cluster for notes on the following `helm get notes <clusterID>-<clusterID> -n <clusterID>`:
- Extract talosctl and kubectl configurations
- Flux bootstrap Workload cluster: Apply FluxInstance and repo secret manifests.
- GitOps: Deploy infrastructure components to Workload cluster
- GitOps: Deploy and configure workload components to Workload cluster

## Repo contents

### /docs/

- Markdown documentation is in the `/docs` directory, with `/mkdocs.yml` configuration file specifying build for a MkDocs site.
- Generate the site `mkdocs build` and check in the contents of the `/site/` directory.
- This is available using github pages here: <https://motttt.github.io/cluster09/site/>
- Cluster09 sample workload deploys this and makes it available at: <https://cluster09-docs.podzone.cloud/>.

### /cluster-chart/

- The `cluster-chart` directory contains the source for a helm chart called `cluster-chart`.
- This chart is used for GitOps managed cluster provisioning in a flux kustomization.
- Chart changes: Update `CHANGES.md` with version change list, and Chart.yaml with the new version number.
- Chart generation: `helm package cluster-chart/`, which creates a new tgz file.
- Chart index generation; `helm repo index .`, which updates the `index.yaml` file.
- Chart publishing: commit and push changes to the git repo
- Chart deployment: Merge master to gh-pages branch.

### /cluster-bootstrap/

- Scripts and templates for manual Management Cluster provisioning.
- As described in Management cluster above.
- Edit and run `createVMDefinition.sh`, and follow the instructions.

### /cluster-manifests/

- Manifests that are applied early in the cluster configuration are served from a static content store.
- These are served at <https://motttt.github.io/cluster09/manifests>, and are accessed as talos `cluster.extraManifests`.
- These are published when merged into the gh-pages branch.

### /cluster-template/

- This directory contains a Cluster API cluster template.
- Use of the Cluster API cluster template has been refactored into the helm chart in the `cluster-chart` directory.

### /clusters/

- This is the directory that flux cluster bootstrap creates, containing flux kustomizations for each cluster.

### /gitops/

- This directory contains *kustomize kustomizations*.
