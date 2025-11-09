# Cluster Bootstrap

To build a cluster, you first need a cluster.

In the absence of a handy cluster to use as a **Management CLuster**, the scripts in this directory can be used to spin up a cluster that can serve as a 
Management Cluster until the capability to provision managed clusters is available. Once the Management Cluster is provisioned, 
the Management Cluster workload can be migrated to a managed cluster, and the original bootstrap cluster decommissioned with a simple terraform destroy command.

These scripts are effectively what were used to provision clusters before evaluation of Cluster API.

Quickstart:

- Place the contents on this directory onto the operator workstation. This should preferably be done by checking out the repo.
- Edit the values defined in `createVMDefinition.sh`, to specify Proxmox cluster details, and cluster dimensions.
- Controlplane machine count,and Worker machine count can be increased by adding more IPs to the concontrolPlaneIPAddresses and workerIPAddresses lists.
- Ensure the talos controlplane-patch.template, and talos-patch.template meet your requirements. Specifically extraManifests will removal, or you will need to serve static manifests locally.
- Make `createVMDefinition.sh` executable and run it. Instructions will be printed to guide you through the following:
- Change to *vms* directory, and run 'terraform init', followed by 'terraform apply -parallelism=1'
- When up and running, the machines will be in talos *maintenance* state, ready to be configured.
- Change to the talos directory, and run the `createCluster.sh` script. This will configure the machines, and provide further instructions:
- Bootstrap the Talos cluster
- Extract kubectl configuration
- Flux bootstrap to Gitops repo.
