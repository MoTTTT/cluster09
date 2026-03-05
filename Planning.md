# Planning: cluster09

> ⚠️ **IMPORTANT**: This project follows the [AgentWorkFlow.md](./AgentWorkFlow.md) pattern.
> - **Primary Task List**: [planning/tasks.md](./planning/tasks.md)
> - **Activity Log**: [planning/changelog.md](./planning/changelog.md)
> - **Task Routing**: High reasoning → Claude Code | Routine/Template → Ollama.

## Current Focus
Establish `openclaw` cluster connectivity and complete Flux bootstrap.

## 1. Backlog (High Level)
- Full migration of `openclaw` application to the new cluster.
- Re-enable logging/observability for new cluster.
- Cleanup legacy cluster manifests.
- **GitOpsGui**: Abstraction layer for management.
- **cluster-chart**: Support additional CAPI/bootstrap providers.

## 2. In Progress / Scheduled (Short Term)
*See [planning/tasks.md](./planning/tasks.md) for detailed task tracking and routing.*

- **Connectivity Recovery**: Reach Management API at `192.168.4.170:6443`.
- **CAPI Validation**: Verify Proxmox provider reconciliation.
- **Cluster Access**: Retrieve `talosconfig`/`kubeconfig`.
- **Flux Bootstrap**: Apply SOPS key and restore infrastructure wiring.
- **Networking**: Configure Gateway/HTTPRoute and Cloudflare NS.
- **Documentation**: Finalize IP Address allocation logic.

## 3. Human Review Required
- [ ] Confirm `thoth.podzone.cloud` vs `.net` TLD for the gateway.
- [ ] Review `gitops-gateway/openclaw/openclaw-gateway.yaml` HTTPRoute.
