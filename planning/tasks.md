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
- **Status**: ✅ Completed (2026-03-07 01:34 GMT)
- **Requirements**: [planning/requirements/connectivity.md](./requirements/connectivity.md)
- **Outcome**: Verified full connectivity to the Management Cluster API. CAPI `openclaw` resource is in the `Provisioned` phase.
- **Subtasks**:
  - [x] Verify `openclaw` CAPI resource status.
  - [x] Check Proxmox provider reconciliation with namespaced secret.

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
- **Status**: ✅ Completed (2026-03-07 01:24 GMT)
- **Requirements**: [planning/requirements/openclaw-deployment.md](./requirements/openclaw-deployment.md)
- **Subtasks**:
  - [x] Retrieve `talosconfig` and `kubeconfig`.
  - [x] Apply SOPS age key to `flux-system` namespace.
  - [x] Restore infrastructure/app wiring in `flux-system/kustomization.yaml`.
  - [x] Verify Flux infrastructure reconciliation (all kustomizations Ready).
  - [x] Clean up duplicate resources in `flux-system/kustomization.yaml` (fixed duplicate registration error).

### [TASK-006] OpenClaw Application Deployment
- **Assigned**: 🧠 Claude Code
- **Status**: 🚀 In Progress (Awaiting reconciliation)
- **Requirements**: [planning/requirements/openclaw-deployment.md](./requirements/openclaw-deployment.md)
- **Goal**: Deploy OpenClaw application via `filipegalo/openclaw-with-brain` Helm chart.
- **Subtasks**:
  - [x] Document OpenClaw deployment requirements (image, config, ports, volumes).
  - [x] Select Helm chart — using `filipegalo/openclaw-with-brain` v0.1.20.
  - [x] Fix HelmRepository URL and chart name in GitOps.
  - [ ] Verify `openclaw` pod status after Flux reconciliation.
  - [ ] Test application connectivity.

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

### [TASK-010] Documentation Maintenance
- **Assigned**: 🦉 OpenClaw
- **Status**: 🔄 Ongoing
- **Goal**: Maintain real-time logs of user instructions and system actions.
- **Files**:
  - [ ] Update `planning/prompts.md` with each new user request.
  - [ ] Update `planning/auditTrail.md` with each system administration action.
  - [ ] Update `planning/changelog.md` with significant milestones.

### [TASK-011] Ollama Model & Resource Recommendations
- **Assigned**: 🦉 OpenClaw
- **Status**: Planned (depends on TASK-008 deployment)
- **Goal**: After Ollama is running, evaluate model performance and produce tuned resource recommendations for the `openclaw` cluster.
- **Subtasks**:
  - [ ] Run baseline performance tests on candidate models (latency, tokens/sec, memory usage).
  - [ ] Evaluate models for each workload: task routing, code generation, documentation, RAG embeddings.
  - [ ] Produce model selection recommendations — update `gitops/gitops-apps/ollama/ollama-values.yaml` `ollama.models` list.
  - [ ] Measure actual CPU and RAM usage under load on the 42-CPU host.
  - [ ] Produce CPU and memory resource recommendations — update `requests`/`limits` in `ollama-values.yaml`.
  - [ ] Document findings in `planning/OllamaModelRecommendations.md`.

### [TASK-012] Refine Provisioning Instructions
- **Assigned**: 🦉 OpenClaw
- **Status**: Planned
- **Goal**: Propose refinements to `docs/AddingClusters.md` and `docs/AddingApplications.md` based on lessons learned from the `openclaw` cluster deployment.
- **Key Lessons to Include**:
  - **Flux Hierarchy**: Avoiding duplicate resource registration in `flux-system/kustomization.yaml`.
  - **DNS/Domain Validation**: Verifying Helm repository URLs before deployment (e.g., the `charts.openclaw.ai` vs `github.io` issue).
  - **SOPS Key Bootstrap**: Standardizing the manual step for installing the `age.agekey` into the `flux-system` namespace.
  - **Context Management**: Procedure for merging extracted kubeconfigs and purging retired contexts on the bastion (`freyr`).

### [TASK-013] Fix Helm Chart Repositories
- **Assigned**: 🧠 Claude Code
- **Status**: ✅ Completed
- **Subtasks**:
  - [x] **OpenClaw**: Switched to community chart `https://serhanekicii.github.io/openclaw-helm`, chart `openclaw-helm`, version `1.3.22`. (filipegalo chart has no GitHub Pages.)
  - [x] **Ollama**: Fixed `ollama-values.yaml` — otwld/ollama v1.x changed schema from flat `ollama.models` list to `ollama.models.pull` list.
  - [x] **Qdrant**: URL `https://qdrant.github.io/qdrant-helm` confirmed valid (HTTP 200). `context deadline exceeded` was likely a transient network issue; no manifest changes needed.

### [TASK-014] GitOpsGUI — Requirements Breakdown & Build Tasks
- **Assigned**: 🧠 Claude Code
- **Status**: ✅ Completed
- **Requirements**: [planning/requirements/gitopsgui.md](./requirements/gitopsgui.md)
- **Output**: [planning/requirements/gitopsgui-tasks.md](./requirements/gitopsgui-tasks.md)
- **Goal**: Break down the GitOpsGUI requirements into implementable build tasks covering API, data model, and UI layers.
- **Subtasks**:
  - [x] Read and analyse `planning/requirements/gitopsgui.md`.
  - [x] Define API resource model: `cluster`, `application`, `change-pipeline` (REST CRUD operations).
  - [x] Design gitops repo as object storage — define directory/file conventions for each resource type.
  - [x] Break down UI views: cluster list/provision, workload list/add, change pipeline view, status dashboard.
  - [x] Identify technology stack (Python FastAPI + React, deployed via Helm on openclaw cluster).
  - [x] Create build task breakdown in `planning/requirements/gitopsgui-tasks.md`.
  - [x] Updated spec for Senior Developer role, Interrogation use cases, change_name field (spec revisions).

### [TASK-015] GitOpsGUI — Phase 1 + 2 Scaffold (GITGUI-001/002)
- **Assigned**: 🧠 Claude Code
- **Status**: ✅ Completed
- **Output**: `src/gitopsgui/`, `pyproject.toml`, `Dockerfile`, `docker-compose.yml`, `Makefile`
- **Subtasks**:
  - [x] `src/gitopsgui/api/` — FastAPI app, routers (clusters, applications, pipelines, prs, status), JWT auth
  - [x] `src/gitopsgui/services/` — service layer skeletons (git, github, cluster, app, pipeline, k8s, kubeconfig)
  - [x] `src/gitopsgui/models/` — Pydantic models (cluster, application, pipeline, pr, status)
  - [x] `src/gitopsgui/frontend/` — React + Vite scaffold with role-aware routing (App.jsx, main.jsx)
  - [x] `pyproject.toml` — Python dependencies (FastAPI, GitPython, PyGithub, kubernetes client)
  - [x] `Dockerfile` — multi-stage: Node frontend build + Python API
  - [x] `docker-compose.yml` — local dev stack with env var wiring
  - [x] `Makefile` — `make dev`, `make test`, `make build`, `make up`

### [TASK-017] Requirements Tracking — GitOpsGUI
- **Assigned**: 🧠 Claude Code
- **Status**: 🔄 Ongoing
- **Goal**: Monitor `planning/requirements/gitopsgui.md` for new or changed requirements and propagate them into task breakdowns, service implementations, and API endpoints.
- **Process**:
  - On each session start, re-read `gitopsgui.md` and diff against the last known state recorded in `planning/requirements/gitopsgui-tasks.md`.
  - For any new requirement: add a task entry to `gitopsgui-tasks.md`, implement the service method, add the API endpoint, and add a unit test.
  - For any changed requirement: update the corresponding task, service, endpoint, and test.
  - Record the last-reviewed version as a comment at the top of `gitopsgui-tasks.md`.
- **Subtasks**:
  - [x] **2026-03-08**: Added `disable_application` operation (line 87 of gitopsgui.md) — new service method, `POST /api/v1/applications/{name}/disable` endpoint, `DisableApplicationRequest` model; updated GITGUI-006, GITGUI-011, GITGUI-018 in tasks.

---

### [TASK-016] Scheduled Code Quality & Security Scans
- **Assigned**: 🧠 Claude Code
- **Status**: Scheduled
- **Goal**: Add automated code scanning to the GitOpsGUI CI pipeline on a regular schedule.
- **Subtasks**:
  - [ ] Add GitHub Actions workflow `.github/workflows/code-scan.yml` triggered on push + weekly schedule.
  - [ ] **Python security scan**: `bandit -r src/` (OWASP-aligned static analysis).
  - [ ] **Python linting/type check**: `ruff check src/` and `mypy src/`.
  - [ ] **Dependency vulnerability scan**: `pip-audit` for Python packages; `npm audit` for frontend.
  - [ ] **SAST/secrets scan**: `trufflesecurity/trufflehog` or `gitleaks` to prevent accidental secret commits.
  - [ ] Upload results as GitHub Actions artifacts and annotate PRs with findings.

## ✅ Completed

- [x] Initialized cluster09 workspace.
- [x] Created `openclaw` cluster definition and `ManagementCluster` entry.
- [x] Updated `cluster-chart` NOTES.txt with streamlined bootstrap.
- [x] Established `AgentWorkFlow.md` for cost/rate management.
- [x] Extracted `openclaw` kubeconfig and cleaned up `freyr` contexts.
- [x] Applied SOPS age key to `openclaw` cluster.
- [x] Restored infrastructure/app wiring in `flux-system/kustomization.yaml`.
