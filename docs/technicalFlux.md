# Flux

## Introduction

Flux is a Kubernetes GitOps Operator. GitOps is the practice of using code repositories as the single source of truth for cluster and workload configuration.

Flux was built by Weaveworks, and donated to the Cloud Native Computing Foundation (CNCF).

Instrumenting a cluster with Flux requires the following:

- A git repo for the cluster definition, with its associated access username and token exported.
- Installing the flux utility on a cluster administrator workstation (with kubectl context set for the target cluster).
- Bootstrapping flux, specifying the git account, repo, branch and path.

When the bootstrap process concludes, the GIT repo will contain the flux-system component manifests, and the target cluster will have flux-system namespace operator components installed. The flux operator with thereafter monitor the git repo for cluster configuration requirement changes, and apply the appropriate cluster adjustments.

## dev environment bootstrap

```sh
flux bootstrap github --context=microk8s --owner=MoTTTT --repository=podzonedev-gitops --branch=main --personal --path=clusters/megalith --token-auth=true
```

## Troubleshooting

- <https://fluxcd.io/flux/cheatsheets/troubleshooting/>

## Notes

- Mac OS flux Installation: `brew install fluxcd/tap/flux`
- Unix install `curl -s https://fluxcd.io/install.sh | sudo bash`
- Create a GITHUB token, and export username and token: `export GITHUB_TOKEN=<token>`; `export GITHUB_USER=MoTTTT`
- Check flux and cluster: `flux check --pre`
- Bootstrap: `flux bootstrap github --context=prod --owner=MoTTTT --repository=admin --branch=main --personal --path=clusters/prod --token-auth=true`
- GitHub token expiry: Delete flux secret, and bootstrap again with new token in context.

```text
??:
brew tap weaveworks/tap
brew install weaveworks/tap/gitops
```

## Resources created by flux

Can be seen on delete: `flux uninstall`

```text
martincolley@Dolmen:~/workspace/admin/clusters/ukdev$ flux uninstall
Are you sure you want to delete Flux and its custom resource definitions: y
► deleting components in flux-system namespace
✔ Deployment/flux-system/helm-controller deleted 
✔ Deployment/flux-system/kustomize-controller deleted 
✔ Deployment/flux-system/notification-controller deleted 
✔ Deployment/flux-system/source-controller deleted 
✔ Service/flux-system/notification-controller deleted 
✔ Service/flux-system/source-controller deleted 
✔ Service/flux-system/webhook-receiver deleted 
✔ NetworkPolicy/flux-system/allow-egress deleted 
✔ NetworkPolicy/flux-system/allow-scraping deleted 
✔ NetworkPolicy/flux-system/allow-webhooks deleted 
✔ ServiceAccount/flux-system/helm-controller deleted 
✔ ServiceAccount/flux-system/kustomize-controller deleted 
✔ ServiceAccount/flux-system/notification-controller deleted 
✔ ServiceAccount/flux-system/source-controller deleted 
✔ ClusterRole/crd-controller-flux-system deleted 
✔ ClusterRole/flux-edit-flux-system deleted 
✔ ClusterRole/flux-view-flux-system deleted 
✔ ClusterRoleBinding/cluster-reconciler-flux-system deleted 
✔ ClusterRoleBinding/crd-controller-flux-system deleted 
► deleting toolkit.fluxcd.io finalizers in all namespaces
✔ GitRepository/flux-system/flux-system finalizers deleted 
✔ Kustomization/flux-system/flux-system finalizers deleted 
► deleting toolkit.fluxcd.io custom resource definitions
✔ CustomResourceDefinition/alerts.notification.toolkit.fluxcd.io deleted 
✔ CustomResourceDefinition/buckets.source.toolkit.fluxcd.io deleted 
✔ CustomResourceDefinition/gitrepositories.source.toolkit.fluxcd.io deleted 
✔ CustomResourceDefinition/helmcharts.source.toolkit.fluxcd.io deleted 
✔ CustomResourceDefinition/helmreleases.helm.toolkit.fluxcd.io deleted 
✔ CustomResourceDefinition/helmrepositories.source.toolkit.fluxcd.io deleted 
✔ CustomResourceDefinition/kustomizations.kustomize.toolkit.fluxcd.io deleted 
✔ CustomResourceDefinition/ocirepositories.source.toolkit.fluxcd.io deleted 
✔ CustomResourceDefinition/providers.notification.toolkit.fluxcd.io deleted 
✔ CustomResourceDefinition/receivers.notification.toolkit.fluxcd.io deleted 
✔ Namespace/flux-system deleted 
✔ uninstall finished
```
