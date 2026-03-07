# GitOpsGUI

Requirements

- As a cluster operator I would like to take a cluster specification and provision a new cluster
- As a cluster operator I would like to take a workload specification and add a workload to the specified cluster
- As a cluster operator I would like to update cluster OS, and kubernetes version
- As a cluster operator I would like to view the status of kustomizations, helm charts, helm releases, and repo synchronisation is the management, and hosted clusters

Deployment platform specification

- Hypervisor Management API URL
- Hypervisor credentials

Cluster specification

- Cluster name
- Deployment platform
- IP Address range
- Cluster dimensions (control plane and worker node counts, CPU and memory per node type, boot volume size, etc)
- GitOps Repo URL (infrastructure configuration, and application configuration)
- Git Repo SOPS encrypted secret

Application specification

- Application name
- Deployment cluster
- Helm repo, chart name, and chart version
- Chart values.yaml file
- If hosted: Application repo URL

Change pipeline specification

- Dev Cluster ID
- ETE Cluster ID
- Production Cluster ID
- Application ID
- Chart version
- Release ID

Application change specification

- If hosted: Application repo branch
- If hosted: Change request ID / Incident ID / Problem ID

Advanced requirements:

- As a cluster operator I would like to view the change pipeline from dev, through end-to-end deployment, to production
- As a cluster operator I would like to view dev and end to end deployment history
- As a cluster operator I would like to view dev and end to end testing results
- As a cluster operator I would like to manage PR approvals for platform change migration deployment.

Technical requirements:

- Implement an API operation for each of the above operations, and those needed for utility operations.
- Use a gitops repo as the underlying cluster, application workload, change pipeline and deployment history object storage
- API Rest resource: cluster, POST takes cluster specification, GET with cluster name returns specification, without returns list of clusters
- API Rest resource: application, POST takes application specification, GET with application name returns specification, without returns list of applications
- API Rest resource: change pipeline, POST takes change pipeline specification, GET with change pipeline name returns specification, without returns list of change pipelines
