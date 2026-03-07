# Task Tracking (cluster09)

## Goals
- Provision and configure OpenClaw Kubernetes cluster on Proxmox.
- Establish `AgentWorkFlow.md` patterns for multi-agent coordination (OpenClaw, Claude Code, Ollama).
- Manage API costs and rate limits via intelligent task routing and local models.

## Routing Legend
- 🧠 **Claude Code**: High reasoning, complex implementation, debugging.
- 🦉 **OpenClaw (Trismegistus)**: Planning, orchestration, sysadmin, task routing.
- 🏠 **Ollama (Phi-3.5)**: Routine tasks, boilerplate, documentation, simple file ops.

---

## 🚀 In Progress

### [TASK-001] Connectivity & CAPI Validation
- **Assigned**: 🦉 OpenClaw
- **Status**: Investigating "no route to host" at `192.168.4.170:6443`.
- **Requirements**: [planning/requirements/connectivity.md](./requirements/connectivity.md)
- **Subtasks**:
  - [ ] Verify `openclaw` CAPI resource status.
  - [ ] Check Proxmox provider reconciliation with namespaced secret.

### [TASK-002] Context & Secret Management
- **Assigned**: 🦉 OpenClaw
- **Status**: ✅ Completed
- **Subtasks**:
  - [x] Apply `proxmox-secret.yaml` to Management Cluster.
  - [x] Clean up `freyr` kubeconfig (remove retired contexts).
  - [x] Add `openclaw` context from Management secret.

### [TASK-003] Cluster Provisioning Verification
- **Assigned**: 🦉 OpenClaw
- **Status**: ✅ Completed
- **Subtasks**:
  - [x] Verify VM initialization on `venus`.
  - [x] Confirm nodes are `Ready` in the `openclaw` context.

---

## 📋 Planned (Scheduled)

### [TASK-004] IP Address Documentation
- **Assigned**: 🏠 Ollama
- **Status**: ⚠️ Subagent stalled (needs retry)
- **Goal**: Create `documentation/IPAdressManagement.md` with 10-IP allocation logic.

### [TASK-005] OpenClaw Cluster Bootstrap
- **Assigned**: 🦉 OpenClaw
- **Status**: ⚠️ Blocked (missing Helm chart)
- **Requirements**: [planning/requirements/openclaw-deployment.md](./requirements/openclaw-deployment.md)
- **Subtasks**:
  - [x] Retrieve `talosconfig` and `kubeconfig`.
  - [x] Apply SOPS age key to `flux-system` namespace.
  - [x] Restore infrastructure/app wiring in `flux-system/kustomization.yaml`.
  - [x] Verify Flux infrastructure reconciliation (all kustomizations Ready).
  - [ ] **BLOCKER**: `https://charts.openclaw.ai/` doesn't exist. Need to create local Helm chart or use raw manifests.
- **Note**: Flux is working perfectly. All infrastructure kustomizations are Applied. OpenClaw application deployment blocked on missing Helm repository.

### [TASK-006] OpenClaw Application Deployment
- **Assigned**: 🧠 Claude Code
- **Status**: ✅ Completed (2026-03-07 01:06 GMT)
- **Requirements**: [planning/requirements/openclaw-deployment.md](./requirements/openclaw-deployment.md)
- **Goal**: Deploy OpenClaw application via `filipegalo/openclaw-with-brain` Helm chart.
- **Subtasks**:
  - [x] Document OpenClaw deployment requirements (image, config, ports, volumes).
  - [x] Select Helm chart — using `filipegalo/openclaw-with-brain` v0.1.20 (see `planning/OpenclawHelmChartSelection.md`).
  - [x] Fix HelmRepository URL (`https://filipegalo.github.io/openclaw-with-brain`) and chart name/version in `gitops/gitops-apps/openclaw/openclaw.yaml`.
  - [ ] Fix CoreDNS upstream forwarders on openclaw cluster (unblocks HelmRepository reconciliation).
  - [ ] Test deployment in openclaw cluster.

### [TASK-007] Networking & Gateway Config
- **Assigned**: 🧠 Claude Code
- **Status**: Scheduled
- **Subtasks**:
  - [ ] Configure HTTPRoute for `thoth.podzone.cloud`.
  - [ ] Update Cloudflare NS records.
  - [ ] Configure bastion server certs/routes.

### [TASK-008] RAG Stack Deployment (Ollama & Qdrant)
- **Assigned**: 🧠 Claude Code
- **Status**: Planned
- **Goal**: Deploy self-hosted RAG infrastructure on the `openclaw` cluster.
- **Reference**: [planning/RAMRecommendation.md](./RAMRecommendation.md)
- **Subtasks**:
  - [ ] **Ollama Deployment**:
    - [ ] Create `gitops/gitops-apps/ollama/` manifests.
    - [ ] Use Helm repo `https://helm.otwld.com/`, chart `otwld/ollama`, version `latest`.
    - [ ] Configure GPU/CPU resources (utilizing the 42 CPU host).
  - [ ] **Qdrant Deployment**:
    - [ ] Create `gitops/gitops-apps/qdrant/` manifests.
    - [ ] Use Helm repo `https://qdrant.github.io/qdrant-helm`, chart `qdrant/qdrant`, version `1.17.0`.
    - [ ] Configure persistence and memory (2-4Gi as per recommendation).

### [TASK-009] Fix Cluster DNS resolution
- **Assigned**: 🧠 Claude Code
- **Status**: Scheduled
- **Goal**: Configure CoreDNS upstream forwarders to resolve external domains.
- **Subtasks**:
  - [ ] Patch CoreDNS ConfigMap to forward to `1.1.1.1` and `8.8.8.8`.
  - [ ] Verify external DNS resolution from within a pod.
  - [ ] Trigger HelmRepository reconciliation once unblocked.

### [TASK-007] AgentSync Repository Migration
- **Assigned**: 🦉 OpenClaw (orchestration) + 🧠 Claude Code (scripting)
- **Status**: Planned
- **Documentation**: [planning/agentsync-migration.md](./agentsync-migration.md)
- **Goal**: Extract reusable agent workflow patterns into standalone `agentsync` repository.
- **Priority**: Medium (valuable long-term, not blocking current work)
- **Awaiting**: Human approval on repository name and public/private decision.

### [TASK-008] Documentation Site
- **Assigned**: 🏠 Ollama
- **Status**: Backlog
- **Goal**: Periodically rebuild and publish cluster09 mkdocs site.

## ✅ Completed
- [x] Initialized cluster09 workspace.
- [x] Created `openclaw` cluster definition and `ManagementCluster` entry.
- [x] Updated `cluster-chart` NOTES.txt with streamlined bootstrap.
- [x] Established `AgentWorkFlow.md` for cost/rate management.
- [x] Extracted `openclaw` kubeconfig and cleaned up `freyr` contexts.
- [x] Applied SOPS age key to `openclaw` cluster.
- [x] Restored infrastructure/app wiring in `flux-system/kustomization.yaml`.
