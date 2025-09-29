# Manifests

During talos node configuration, a set of kubernetes manifests are loaded.

These are cached in the Cluster09 repo, and served from the web server in the management cluster.

Their configuration can be found in the Cluster template, in the cluster.extraManifests array.

| manifest name                         | Source                                                                                                                                                       |
|---------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| kubelet-serving-cert-approver.yaml    | <https://raw.githubusercontent.com/alex1989hu/kubelet-serving-cert-approver/main/deploy/standalone-install.yaml>                                             |
| metrics-server.yaml                   | <https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml>                                                                 |
| piraeus-operator.yaml                 | <https://github.com/piraeusdatastore/piraeus-operator/releases/latest/download/manifest.yaml>                                                                |
| gateway-api.yaml                      | <https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml>                                                              |
| cilium.yaml                           | helm template \                                                                                                                                              |
|                                       |     cilium \                                                                                                                                                 |
|                                       |     cilium/cilium \                                                                                                                                          |
|                                       |     --version 1.17.4 \                                                                                                                                       |
|                                       |     --set hubble.relay.enabled=true \                                                                                                                        |
|                                       |     --set hubble.ui.enabled=true \                                                                                                                           |
|                                       |     --set ingressController.enabled=true \                                                                                                                   |
|                                       |     --set ingressController.loadbalancerMode=shared \                                                                                                        |
|                                       |     --set ingressController.default=true \                                                                                                                   |
|                                       |     --set l2announcements.enabled=true \                                                                                                                     |
|                                       |     --set l2announcements.leaseDuration=3s \                                                                                                                 |
|                                       |     --set l2announcements.leaseRenewDeadline=1s \                                                                                                            |
|                                       |     --set l2announcements.leaseRetryPeriod=200ms \                                                                                                           |
|                                       |     --set loadBalancerIPs.enable=true \                                                                                                                      |
|                                       |     --set gatewayAPI.enabled=true \                                                                                                                          |
|                                       |     --set loadBalancer.l7.backend=envoy \                                                                                                                    |
|                                       |     --namespace kube-system \                                                                                                                                |
|                                       |     --set ipam.mode=kubernetes \                                                                                                                             |
|                                       |     --set kubeProxyReplacement=true \                                                                                                                        |
|                                       |     --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" \      |
|                                       |     --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" \                                                               |
|                                       |     --set cgroup.autoMount.enabled=false \                                                                                                                   |
|                                       |     --set cgroup.hostRoot=/sys/fs/cgroup \                                                                                                                   |
|                                       |     --set k8sServiceHost=localhost \                                                                                                                         |
|                                       |     --set k8sServicePort=7445 > cilium.yaml                                                                                                                  |




















```
