# GitOpsGUI — Open Blockers & Questions

Raised after Phase 1+2 implementation. Please review before Phase 3 begins.

---

## B1 — GitHub Repo Name (GITGUI-004) ✅ Resolved

Two repos in play:
- **GitOps repo** (where cluster/app/pipeline PRs are created): `motttt/cluster09` — inferred from `https://motttt.github.io/cluster09/` HelmRepository URL. Set `GITHUB_REPO=motttt/cluster09`.
- **Application source repo**: named `GitOpsAPI` — this is where the GitOpsGUI/API source code will live.

`docker-compose.yml` default updated to `GITHUB_REPO=motttt/cluster09`.

---

## B2 — SSH Deploy Key Secret Name (GITGUI-003, GITGUI-024)

The git service uses `GITOPS_SSH_KEY_PATH` (default: `/etc/gitops-ssh/id_rsa`).
This should be mounted from a Kubernetes secret.
**Question**: What is the name of the SSH deploy key secret, or do you want one created fresh?

---

## B3 — openclaw-helm Chart Name (TASK-013)

`openclaw.yaml` now references chart `openclaw-helm` v1.3.22 from `serhanekicii.github.io/openclaw-helm`.
The actual chart name inside the index may differ (e.g. `openclaw`).
**Action needed**: Once Flux reconciles, check `kubectl get helmrelease -n flux-system openclaw` for the exact error and confirm/correct the chart name.

---

## B4 — GitOpsGUI Hostname (GITGUI-022/023)

A HTTPRoute is needed for the GitOpsGUI application.
**Question**: What hostname should GitOpsGUI be served on? (e.g. `gitops.podzone.cloud`)

---

## B5 — PR Reviewer GitHub Usernames (GITGUI-004/025)

The PR service needs the GitHub usernames of `build-managers` and `cluster-operators` to assign as required reviewers.
These can be supplied via environment variables or a config file, or derived from GitHub team membership.
**Question**: Do you have existing GitHub teams set up, or should the chart values accept a comma-separated list of reviewer usernames?

---

## B6 — SOPS Age Key Secret Format (GITGUI-009)

The kubeconfig service needs the repo's SOPS age private key to decrypt `kubeconfig.sops.yaml` files.
**Question**: Is the age key already in a Kubernetes secret on the openclaw cluster? If so, what secret name/namespace?
(The public key is in `.sops.public.key` in the repo root.)

---

## B7 — Management Cluster Kubeconfig Secret (GITGUI-009)

The service needs a kubeconfig for the management cluster to extract CAPI `<cluster>-kubeconfig` secrets.
**Question**: Which cluster is the management cluster, and is there already a kubeconfig secret that GitOpsGUI can use?

---

## Next Phase

Once blockers B1–B2 are answered, Phase 3 (K8s/Flux status service — GITGUI-008/009) can be implemented.
Phase 4 (REST API) is already scaffolded; routers are wired to the service layer.
Phase 5 (Frontend views) can begin in parallel once the API contract is stable.
