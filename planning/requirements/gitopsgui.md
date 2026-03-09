# GitOpsGUI

Requirements

- As a cluster operator I would like to take a cluster specification and provision a new cluster
- As a cluster operator I would like to take a workload specification and add a workload to the specified cluster
- As a cluster operator I would like to update cluster OS, and kubernetes version
- As a cluster operator I would like to view the status of kustomizations, helm charts, helm releases, and repo synchronisation is the management, and hosted clusters
- As a cluster operator I would like to view the change pipeline from dev, through end-to-end deployment, to production
- As a cluster operator I would like to view dev and end to end deployment history
- As a cluster operator I would like to view dev and end to end testing results
- As a cluster operator I would like to view PR reviews for platform change migration deployment.
- As a cluster operator I would like to manage PR approvals for platform change migration deployment.
- As a build manager I would like to add a change pipeline specification
- As a build manager I would like to trigger RP approvals for a change pipeline, from reviews detail and approval list views
- As a build manager I would like to extract dev and end-to-end kubeconfig credentials
- As a cluster operator I would like to extract dev, end-to-end, and production kubeconfig credentials
- Business rule: Deployment to dev can be approved by build manager
- Business rule: Deployment to end-to-end can be approved by build manager
- Business rule: Deployment to production requires approval by both cluster operators and build manager
- Note that these need to be enforced at the git forge repo access and authorisation level
- As a senior developer I would like to extract dev and end-to-end kubeconfig credentials
- As a senior developer, build manager, and cluster operator, I would like use Interrogation use cases

- Interrogation use cases:
- I would like to view gitops status {repo sync, flux gitops infrastructure and application kustomizations, chart repo, chart release, deloyments, pods, etc}
- I would like to zoom in on a gitops status, to see the detail of the object (k8s describe)
- I would like to zoom in on a gitops status, to see the logs of the object (k8s logs) if applicable
- I would like to list applications, releases, clusters, change pipelines, and application change specifications, and review and approval status

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
- Cluster kubeconfig (generated, extracted from management cluster, redacted/SOPS encrypted)

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

Application change specification required for hosted developments

- Change request ID / Incident ID / Problem ID
- Change Name
- Change description
- Application repo branch

GitOps Git repo specification

- Guard rails for change review and approvals on repo configuration
- Make use of git forge features to record and manage PR communications
- Tag git repos with deployment (git PM merge approval commit)
- cluster operator and build manager approve PR merge

Technical requirements:

- Implement an API operation for each of the above operations, and those needed for utility operations.
- Use a gitops repo as the underlying cluster, application workload, change pipeline and deployment history object storage
- API Rest resource: cluster, POST takes cluster specification, GET with cluster name returns specification, without returns list of clusters
- API Rest resource: application, POST takes application specification, GET with application name returns specification, without returns list of applications
- API Rest resource: change pipeline, POST takes change pipeline specification, GET with change pipeline name returns specification, without returns list of change pipelines
- GitOpsGUI refers to the Front end that calls the API
- GitOpsAPI Uses git git review and approval process to govern change progression to production. This triggers target cluster changes via the git gitops sync process
- management cluster k8s cluster API credentials for the management cluster required to extract new cluster kubeconfig entries to encrypt and add to cluster specification
- To disable an application (delete from the cluster, while retaining definition, and network configuration), comment out applicable kustomization in <clusters/<cluster name>/<application name>-apps.yaml 

