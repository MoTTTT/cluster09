# Planning: cluster09

## 1. Backlog
- Full migration of `openclaw` application to the new dedicated cluster.
- Re-enabling logging (fluentbit) and observability for the new cluster environment.
- Post-migration cleanup of legacy cluster definitions and unused manifests.
- **GitOpsGui**: An abstraction layer on top of cluster and workload management.
- **cluster-chart**: Add support for default CAPI cluster and bootstrap providers (i.e. in addition to talos).
- **Documentation**: Build out cluster09 mkdocs site.
- **gitops-apps/observability**: Refactor to use opensearch operator helm chart.

## 2. Tasks in breakdown
- **Connectivity Recovery**: Investigate the "no route to host" error when reaching the Management Cluster API at `192.168.4.170:6443`.
- **CAPI Validation**: Verify the status of the `openclaw` Cluster API resource and ensure the Proxmox provider is reconciling correctly with the namespaced secret.
- **Evaluate openclaw installation**:
    - [ ] **Get Access to Cluster**: Retrieve `talosconfig` and `kubeconfig` secrets from the Management Cluster. (Testing/Refining `NOTES.txt` instructions).
    - [ ] **Streamlined Flux Bootstrap**: Implement the simplified bootstrap process (apply SOPS key to `flux-system` namespace; core manifests pre-loaded via Talos `extraManifests`).
    - [ ] **Check Flux Status**: Verify reconciliation on the new cluster.
    - [ ] **Fix Networking**: Configure Gateway/HTTPRoute for `thoth.podzone.cloud`, Cloudflare NS record, and bastion server cert/route.

## 3. Tasks scheduled
- [ ] **Secret Application**: Manually apply the `proxmox-secret.yaml` (with `openclaw` namespace) to the management cluster via `freyr`.
- [ ] **Hypervisor Check**: Run `qm list` on `venus` (192.168.4.50) to confirm if `openclaw-control-plane` and `openclaw-worker` VMs have been initialized.
- [ ] **Context Update & Cleanup**: On `freyr`, remove retired contexts (`cluster08`, `wso2`, `management`) and add the `openclaw` context from the `openclaw-kubeconfig` secret.
- [ ] **IP Documentation**: Create `documentation/IPAdressManagement.md` documenting the 10-IP allocation logic and current ranges.
- [ ] **Gateway Manifests**: Create `gitops/gitops-gateway/openclaw/openclaw-gateway.yaml` for `thoth.podzone.cloud` (verify TLD: .cloud vs .net).
- [ ] **Bootstrap Wiring**: Restore `- ../infrastructure.yaml` and `- ../openclaw-apps.yaml` to `clusters/openclaw/flux-system/kustomization.yaml` once nodes are Ready.
