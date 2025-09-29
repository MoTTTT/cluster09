# Cluster09, a PodZone project

This repo contains a bootstraping and scaffolding and configuration for

- A Cluster API management cluster
- Cluster API template for a kubernetes cluster
- Template input to instantiate a managed cluster (Cluster09)
- Cluster09 gitops infrastructure configuration (Storage, Networking, Gateway)
- Cluster09 gitops workload configuration (Visibility tools)
- Cluster09 gitops authC authZ services (Fine grained and delegated access control

## Cluster API management cluster

- Scripts to substitute instance variables into templates, for the bootstrapping of a Cluster API management cluster, and providing notes on user driven configuration.
- Templates generated Teraform VM definitions
- Templates for generated Talos configuration
- Script for Talos configuration form generated configurations

## Technology considerations

### Specification

- Automated, repeatable cluster provisioning
- Provisioning scaffolding, (clean slate environments)
- Isolated provisioning (airgapped environment bootstrap)

### Dependency management

To support airgapped green-fields deployment, all dependencies need to be met locally. To leverage automated deployments, the following cached (and therefore version controlled) information is required.

- Local image mirror
- local config repo, with documentation, configuration, and scripts
- manifest repo, with cluster09 cluster and workload manifests
- tested with network airgapped bootstrap to workload commissioned
- Type approved bastion or bootstrap server configuration and build notes

## CAPI: Process, Component, and Workflow

- Talos for CAPI management cluster
- Terraform for CAPI cluster VMs
- Bash for CAPI Terraform and Talos template substitution
- Manual Terraform execution
- Scripted Talos Installation for CAPI
- Manual Talos cluster bootstrapping
- Manual access configuration extraction
- Manual gitops CAPI cluster workload bootstrapping (for future cluster API operator)
- Manual clusterctl CAPI cluster workload bootstrapping 

## Cluster09: Process, Components, and Workflow

- Cluster template for proxmox and talos provided cluster
- Manual cluster configuration
- clustercli manifest generation from template, and configuration
- gitops  

## Platform: Process, Components, and Workflow

- Proxmox hypervisor
- Talos for management and provisioned clusters (Cluster09)

## Proxmox hypervisor

- Proxmox V9 installed
