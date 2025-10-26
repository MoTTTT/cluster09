# Using the Cluster API template

This section describes the use of a running cluster api management cluster.

## Pre-requisites

- kubectl installed
- clusterctl installed
- Running cluster api management cluster

## Usage

- Generate variable list from cluster-template: `clusterctl generate yaml --list-variables --from cluster-template.yaml | grep -v Variables | sed -e 's/^  - //g' | sed -e 's/$/=/g' > clusterctl-editme.yaml`
- Edit `clusterctl-editme.yaml`, adding values, and place in `~/.config/cluster-api/clusterctl.yaml`
- Generate cluster manifest: `clusterctl generate yaml --from cluster-template.yaml > cluster09.yaml`
- Ensure that you are using the correct cluster context for your cluster-api management cluster: `kubectl config get-contexts`, `kubectl config set-context ...`
