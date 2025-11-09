# Cluster API Cluster Template

A Cluster API Cluster Template can be used to abstract cluster specifications from cluster operations.

A CAPI Management cluster operator responsible for cluster instantiation provided with the necessary specification can instantiate a cluster in three steps:

1) Extract the variables that require values for the target cluster from the template: `clusterctl generate yaml --list-variables --from cluster-template.yaml`
2) Specify the values in `~/.cluster-api/clusterctl.yaml` on the operator workstation, testing by viewing the generated manifests:`clusterctl generate yaml --from cluster-template.yaml`
3) Apply the manifest to the cluster, or add the generated manifest to a gitops.

Use of the Cluster API Cluster Template, which has been refactored into the cluster-chart helm chart, has been replaced with a flux kustomization.
This uses a helm values.yaml in the Management cluster GitOps repoto configure the cluster-chart helm chart release, instead of using the `~/.cluster-api/clusterctl.yaml` file on a workstation.
The templates are retained in this repo for reference, and are not maintained.
