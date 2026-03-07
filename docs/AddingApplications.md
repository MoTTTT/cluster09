# Adding Applications

Once the Workload cluster is provisioned, and it's infrastructure components stable, additional application workloads can be added as follows:

Specification: 

- Helm repo and helm chart for the application <application name>
- Chart version
- Kubernetes namespace for the application - also <application name>

For a new application, add a directory to the gitops/gitops-apps directory in the GitOps repo:

- Clone an existing cluster specification, e.g.  gitops/gitops-apps/observability to create /gitops/gitops-apps/<application name>
- Rename and Edit /gitops/gitops-apps/<application name> files, setting filenames and namespaces to the application name, as demonstrated in the pattern from the cloned observability example. Set the helm repo, helm chart, and repo name as specified.

Deployment:

Specification: Deployment cluster <cluster name>

For a new cluster deployment: Add a kustomization to clusters/<cluster name>/applications.yaml pointing to /gitops/gitops-apps/<application name>, using an example yalm file such as infrastructure.yaml, or another cluster's applications.yaml

