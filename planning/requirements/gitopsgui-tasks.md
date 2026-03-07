# GitOpsGUI — Build Task Breakdown

**Source requirements**: [gitopsgui.md](./gitopsgui.md)
**Assigned**: 🧠 Claude Code
**Status**: Planning

---

## Architecture Clarification

- **GitOpsGUI**: React frontend — the operator/manager-facing web interface
- **GitOpsAPI**: Python FastAPI backend — implements REST operations, uses the **git PR review and approval process** as the governance mechanism for change progression to production. All writes to the gitops repo go via PRs, not direct commits. Flux picks up merged changes and reconciles target clusters.

---

## User Roles

| Role | Responsibilities |
|---|---|
| Cluster Operator | Provision clusters, add workloads, view cluster/app/Flux status, approve PRs for platform changes, extract kubeconfig for dev/ETE/production clusters |
| Build Manager | Define change pipelines, track dev→ETE→prod progression, view/manage PR approvals, view test results and deployment history, extract kubeconfig for dev/ETE clusters |

---

## Technology Stack

| Layer | Technology | Rationale |
|---|---|---|
| Backend API (GitOpsAPI) | Python + FastAPI | Clean REST, native Kubernetes client, GitPython for repo/PR ops |
| Git operations | GitPython + GitHub API (PyGitHub) | Read/write files; create and manage PRs via GitHub API |
| Kubernetes status | `kubernetes` Python client | Query Flux kustomizations, HelmReleases, pod status |
| Frontend (GitOpsGUI) | React + Vite | Role-aware views for Cluster Operator and Build Manager |
| Auth | OAuth2 proxy (existing) + Keycloak | Already deployed in `gitops/gitops-apps/security/`; roles via Keycloak groups |
| Container | Docker, multi-stage build | Build frontend, serve static via FastAPI |
| Deployment | Helm chart in `charts/gitopsgui/` | Consistent with repo pattern; deployed as Flux app |
| Ingress | HTTPRoute via existing Gateway | Consistent with openclaw/thoth pattern |

---

## Gitops Repo as Object Storage — Conventions

All writes go via feature branches + PRs. Flux reconciles after PR merge.

| Resource | Repo path | Key files |
|---|---|---|
| Cluster | `clusters/<name>/` | `flux-system/kustomization.yaml`, values in `gitops/cluster-charts/<name>/`, `kubeconfig.sops.yaml` (SOPS-encrypted) |
| Application | `gitops/gitops-apps/<name>/` | `<name>.yaml`, `<name>-values.yaml`, `kustomization.yaml` |
| Change Pipeline | `pipelines/<name>/` | `pipeline.yaml` — dev/ETE/prod cluster IDs, app ID, chart version, release ID |
| App Change Spec | `pipelines/<name>/changes/<change-id>/` | `change.yaml` — change request ID, description, branch |
| Deployment History | `pipelines/<name>/history/` | Per-release YAML records with timestamps and status |
| Test Results | `pipelines/<name>/history/<release-id>/tests/` | Test result YAML/JSON per run |

### PR Governance Model

Approval requirements are enforced at the **git forge level** (GitHub branch protection rules) — not just in the API.

| Deployment target | Required approvals |
|---|---|
| Dev cluster | Build Manager |
| ETE cluster | Build Manager |
| Production cluster | Cluster Operator **and** Build Manager |

```
Write operation
    → create feature branch
    → commit changes
    → open PR (labelled: cluster/application/pipeline/promotion + target stage)
    → required reviewers notified (determined by target stage)
    → reviews submitted via GitOpsGUI or GitHub directly
    → merge (branch protection enforces approvals)
    → git tag applied to merge commit: <pipeline>-<stage>-<release-id>
    → Flux detects change on main, reconciles target cluster
```

---

## Build Tasks

### Phase 1 — Project Scaffold

#### [GITGUI-001] Initialise project structure
- Create `src/gitopsgui/` with:
  - `api/` — FastAPI app and routers
  - `services/` — git, github, kubernetes, flux service layer
  - `models/` — Pydantic request/response models
  - `frontend/` — React + Vite app
- Add `Dockerfile` (multi-stage: build frontend, serve via FastAPI static)
- Add `requirements.txt` / `pyproject.toml`
- Environment variables: `GITOPS_REPO_URL`, `GITOPS_BRANCH`, `GITHUB_TOKEN`, `GITHUB_REPO`

#### [GITGUI-002] Local development environment
- `docker-compose.yml` for local dev (API + mock git repo volume)
- `Makefile` with `make dev`, `make test`, `make build`

---

### Phase 2 — Git Service Layer

#### [GITGUI-003] Git repo service (branch + PR workflow)
- Clone/pull gitops repo on startup
- Implement `read_file(path)` helper
- Implement `create_branch(branch_name)`, `write_file(path, content)`, `commit(message)`, `push()` helpers
- **No direct commits to `main`** — all writes go via branches
- Handle SSH key auth via mounted secret

#### [GITGUI-004] GitHub PR service
- `create_pr(branch, title, body, labels, reviewers)` — opens PR via GitHub API (PyGitHub)
  - Labels: resource type (`cluster`, `application`, `pipeline`, `promotion`) + target stage (`dev`, `ete`, `production`)
  - Assign reviewers based on target stage: build manager only (dev/ETE), both roles (production)
- `list_prs(state, label)` — list open/merged PRs for the gitops repo
- `get_pr(pr_number)` — PR details, review status, approvals, required vs actual approvers
- `approve_pr(pr_number, user)` — submit approval review
- `merge_pr(pr_number)` — merge after forge-enforced approvals satisfied
- `tag_deployment(commit_sha, tag)` — apply git tag `<pipeline>-<stage>-<release-id>` to the merge commit, recording deployment provenance

#### [GITGUI-005] Cluster object reader/writer
- `list_clusters()` — enumerate `clusters/` directories
- `get_cluster(name)` — parse `gitops/cluster-charts/<name>/<name>-values.yaml`
- `create_cluster(spec)` — render cluster chart values + kustomization, commit to branch, open PR

#### [GITGUI-006] Application object reader/writer
- `list_applications()` — enumerate `gitops/gitops-apps/` directories
- `get_application(name)` — parse `gitops/gitops-apps/<name>/<name>.yaml`
- `create_application(spec)` — render HelmRepository + HelmRelease + kustomization, commit, open PR

#### [GITGUI-007] Change pipeline object reader/writer
- `pipeline.yaml` schema: dev_cluster_id, ete_cluster_id, prod_cluster_id, app_id, chart_version, release_id
- `list_pipelines()`, `get_pipeline(name)`, `create_pipeline(spec)` — writes + PR
- `create_change(pipeline, change_spec)` — writes `changes/<change-id>/change.yaml` (change_request_id, description, branch), opens PR
- `record_deployment(pipeline, release_id, status)` — append to `history/`
- `record_test_results(pipeline, release_id, results)` — write to `history/<release-id>/tests/`

---

### Phase 3 — Kubernetes Status Service

#### [GITGUI-008] Flux status queries
- `get_kustomization_status(name, namespace)` — Flux `kustomize.toolkit.fluxcd.io/v1` resource
- `get_helmrelease_status(name, namespace)` — Flux `helm.toolkit.fluxcd.io/v2` resource
- `get_helmrepository_status(name, namespace)`
- `list_all_flux_status(cluster)` — aggregate status for dashboard view

#### [GITGUI-009] Kubeconfig extraction service
- Connect to the management cluster using a dedicated management cluster kubeconfig (env: `MGMT_KUBECONFIG_SECRET`)
- `extract_kubeconfig(cluster_name)` — read the new cluster's kubeconfig from the management cluster's CAPI secret (`<cluster-name>-kubeconfig` in the cluster namespace)
- `sops_encrypt(kubeconfig_yaml)` — encrypt with the repo's age key before storing
- `store_kubeconfig(cluster_name, encrypted_kubeconfig)` — write `clusters/<name>/kubeconfig.sops.yaml` to gitops repo (via PR), updating the cluster spec
- `get_kubeconfig(cluster_name, caller_role)` — decrypt and return kubeconfig, role-gated:
  - Build Manager: dev and ETE clusters only
  - Cluster Operator: dev, ETE, and production clusters
- Internal: per-request context switching for Flux/status queries using decrypted kubeconfigs

---

### Phase 4 — REST API (GitOpsAPI)

#### [GITGUI-010] Cluster API endpoints
```
POST   /api/v1/clusters                    — provision new cluster (creates PR)
GET    /api/v1/clusters                    — list clusters with Flux status
GET    /api/v1/clusters/{name}             — get cluster spec + live status
PATCH  /api/v1/clusters/{name}             — update OS/k8s version (creates PR)
GET    /api/v1/clusters/{name}/kubeconfig  — download decrypted kubeconfig (role-gated: build manager=dev/ETE only, cluster operator=all)
```

#### [GITGUI-011] Application API endpoints
```
POST   /api/v1/applications          — add workload to cluster (creates PR)
GET    /api/v1/applications          — list applications with HelmRelease status
GET    /api/v1/applications/{name}   — get application spec + live status
```

#### [GITGUI-012] Change pipeline API endpoints
```
POST   /api/v1/pipelines                              — create pipeline (creates PR)
GET    /api/v1/pipelines                              — list pipelines
GET    /api/v1/pipelines/{name}                       — get pipeline spec
POST   /api/v1/pipelines/{name}/changes               — add change spec (creates PR)
GET    /api/v1/pipelines/{name}/history               — deployment history
GET    /api/v1/pipelines/{name}/history/{id}/tests    — test results for a release
POST   /api/v1/pipelines/{name}/promote               — promote to next stage (creates PR)
```

#### [GITGUI-013] PR management API endpoints

```
GET    /api/v1/prs                     — list open PRs (filterable by type, label, stage)
GET    /api/v1/prs/{pr_number}         — PR detail: diff, reviews, required approvers, approval status
POST   /api/v1/prs/{pr_number}/approve — submit approval (role-gated per business rules below)
POST   /api/v1/prs/{pr_number}/merge   — merge (only callable when forge-enforced approvals satisfied)
```

Business rule enforcement:
- **Dev / ETE PRs**: labelled `stage:dev` or `stage:ete` — build manager approval sufficient; API assigns build manager as required reviewer
- **Production PRs**: labelled `stage:production` — both cluster operator AND build manager required; API assigns both as required reviewers
- Enforcement is **primarily at the forge level** (branch protection rules — see GITGUI-025); the API mirrors the same rules for display and UX guidance
- The `/approve` endpoint checks caller role against PR stage label and returns 403 if the role is not permitted to approve that stage

#### [GITGUI-014] Status API endpoint
```
GET    /api/v1/status              — aggregate Flux status across all clusters
GET    /api/v1/status/{cluster}    — per-cluster kustomization + HelmRelease summary
```

---

### Phase 5 — Frontend (GitOpsGUI)

#### [GITGUI-015] App shell, routing and role-aware nav
- React Router with views grouped by role
- Auth: redirect to Keycloak via OAuth2 proxy; read role from JWT (`cluster_operator` / `build_manager`)
- Cluster Operator nav: Dashboard, Clusters, Applications, PR Reviews
- Build Manager nav: Pipelines, PR Reviews, Test Results, Deployment History
- Global Flux sync status indicator in header

#### [GITGUI-016] Status dashboard (Cluster Operator)
- Aggregate view: clusters, kustomizations, HelmReleases, HelmRepositories with status badges
- Filter by cluster, status
- Auto-refresh every 30s

#### [GITGUI-017] Cluster list + provision form (Cluster Operator)
- Table: cluster name, node count, Flux status, k8s version
- Provision form: cluster name, platform, IP range, dimensions, GitOps repo URL, SOPS secret reference
- Submit → `POST /api/v1/clusters` → shows resulting PR link
- Per-cluster "Download kubeconfig" button → `GET /api/v1/clusters/{name}/kubeconfig` → downloads file; production cluster button shown to cluster operators only

#### [GITGUI-018] Application list + add workload form (Cluster Operator)
- Table: app name, target cluster, chart, version, HelmRelease status
- Add form: app name, cluster, Helm repo URL, chart name, version, values.yaml editor
- Submit → `POST /api/v1/applications` → shows resulting PR link

#### [GITGUI-019] PR review and approval view (Cluster Operator + Build Manager)
- List of open PRs with type badge (cluster / application / pipeline / promotion)
- PR detail: diff viewer, review status, existing approvals
- Approve button (role-gated) → `POST /api/v1/prs/{pr_number}/approve`
- Merge button (visible when approvals satisfied) → `POST /api/v1/prs/{pr_number}/merge`

#### [GITGUI-020] Change pipeline view (Build Manager)
- Pipeline swimlane: Dev → ETE → Production
- Per-stage: chart version deployed, last reconcile time, Flux status
- Add change spec form: change request ID, description, app branch → `POST /api/v1/pipelines/{name}/changes`
- Promote button → `POST /api/v1/pipelines/{name}/promote` → shows resulting PR link
- Per-stage "Download kubeconfig" button for dev and ETE stages → `GET /api/v1/clusters/{cluster_id}/kubeconfig`

#### [GITGUI-021] Deployment history + test results (Build Manager)
- Timeline view of releases per pipeline
- Per-release: status, timestamp, PR link, deployed chart version
- Test results tab: pass/fail counts, test case list, raw output link

---

### Phase 6 — Deployment

#### [GITGUI-022] Helm chart for GitOpsGUI
- Create `charts/gitopsgui/` following `cluster-chart` conventions
- Configurable: image tag, git repo URL/branch, SSH secret name, GitHub token secret name, kubeconfig secret name
- Service + Deployment + HTTPRoute template

#### [GITGUI-023] GitOps wiring
- Create `gitops/gitops-apps/gitopsgui/` following openclaw/ollama pattern
- HelmRelease + values ConfigMap
- Add kustomization to `clusters/openclaw/openclaw-apps.yaml`

#### [GITGUI-025] GitHub repository and branch protection configuration
- Configure branch protection on `main` in the cluster09 gitops repo to enforce business rules:
  - Require PR before merging (no direct pushes)
  - **Dev/ETE promotion PRs** (label `stage:dev`, `stage:ete`): require 1 approval from `build-managers` CODEOWNERS team
  - **Production promotion PRs** (label `stage:production`): require 1 approval from `build-managers` AND 1 from `cluster-operators` CODEOWNERS team
- Add `CODEOWNERS` file to repo root mapping pipeline paths to teams:
  ```
  pipelines/*/  @org/build-managers @org/cluster-operators
  clusters/*/   @org/cluster-operators
  gitops/gitops-apps/*/  @org/cluster-operators
  ```
- Configure GitHub teams: `build-managers`, `cluster-operators` — sync membership with Keycloak groups
- Enable "Require conversation resolution before merging"
- Enable signed commits (optional, for stronger deployment provenance alongside git tags)
- Document repo configuration steps in `docs/GitOpsRepoSetup.md`

#### [GITGUI-024] Secrets and RBAC
- Kubernetes secret for SSH deploy key (git push access)
- Kubernetes secret for GitHub token (PR creation/management)
- Kubernetes secret for **management cluster kubeconfig** — used to extract new cluster kubeconfigs via CAPI secrets
- Kubernetes secret for age key — used by GITGUI-009 to SOPS-encrypt kubeconfigs before writing to gitops repo
- ClusterRole for Flux resource reads
- Keycloak groups: `cluster-operators`, `build-managers` — map to app roles
- Document secret creation commands in chart NOTES.txt

---

## Dependency Order

```
GITGUI-001 → GITGUI-002
           → GITGUI-003 → GITGUI-004
                        → GITGUI-005 → GITGUI-010
                        → GITGUI-006 → GITGUI-011
                        → GITGUI-007 → GITGUI-012
           → GITGUI-004 → GITGUI-013
           → GITGUI-008 → GITGUI-009 → GITGUI-014
GITGUI-010..014 → GITGUI-015..021 (frontend)
GITGUI-001..021 → GITGUI-022 → GITGUI-023 → GITGUI-024
```

---

## Open Questions (for human decision)

1. ~~**Multi-cluster kubeconfig delivery**~~ ✅ **Resolved**: Fetch dynamically from management cluster CAPI secrets (`<cluster>-kubeconfig` secret), SOPS-encrypt with repo age key, store in `clusters/<name>/kubeconfig.sops.yaml` in gitops repo. API decrypts on demand and serves role-gated via `GET /api/v1/clusters/{name}/kubeconfig`.
2. ~~**Git write strategy**~~ ✅ **Resolved**: All writes via PRs. Cluster operators and build managers approve. Flux reconciles on merge.
3. ~~**Frontend hosting**~~ ✅ **Resolved**: Serve React build as FastAPI static files — single container, consistent with repo pattern, appropriate for an internal operator tool.
4. ~~**Promotion approval**~~ ✅ **Resolved**: Dev and ETE — build manager sufficient. Production — both cluster operator AND build manager required. Enforced at git forge level via branch protection + CODEOWNERS (GITGUI-025).
