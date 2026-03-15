# cluster09 — Claude Code session context

## Ownership warning
**Trismagistus owns this repo.** Claude Code makes changes here only when explicitly
instructed — typically for manifest seeding or emergency fixes. Default: read only.

This is the monolithic GitOps repo currently being split into per-cluster repos (CC-028).
New work goes into the per-cluster repos (`gitopsdev-apps`, `gitopsdev-infra`, etc.),
not here, unless the task specifically targets cluster09.

## Repo layout
```
clusters/<name>/            — Flux Kustomization wiring per cluster
gitops/
  cluster-charts/<name>/    — cluster-chart HelmRelease + values per cluster
  gitops-apps/<name>/       — application HelmRelease + values (legacy, being split)
  gitops-gateway/<name>/    — Gateway API manifests per cluster
  gitops-infra/             — shared infrastructure manifests
  gitops-management/        — management cluster manifests
cluster-chart/              — Helm chart source for cluster provisioning
```

## Active clusters
| Cluster | Control plane | LB pool | Flux repo |
|---|---|---|---|
| Management | 192.168.4.211 | 192.168.4.218–219 | cluster09 (transitional) |
| gitopsdev | 192.168.4.120 | 192.168.4.128–129 | gitopsdev-infra + gitopsdev-apps |
| openclaw | 192.168.4.170 | 192.168.4.178–179 | cluster09 (transitional) |
| gitopsete | TBD | TBD | gitopsete-infra + gitopsete-apps (planned) |

## SOPS conventions
- Management SOPS age key: on freyr bastion host — root credential for all cluster recovery
- Per-cluster SOPS keys: stored encrypted at `management-infra/sops-keys/{cluster}.agekey.enc`
- Per-repo deploy key private keys: stored encrypted at `management-infra/secrets/{cluster}/`
- `.sops.yaml` at repo root defines which public keys can encrypt/decrypt

## kubectl access
Direct cluster IPs require Cloudflare WARP VPN. When VPN is down, use freyr port-forwards:
```bash
kubectl --context gitopsdev-admin@gitopsdev --server=https://192.168.1.80:6442 ...
kubectl --context openclaw-admin@openclaw   --server=https://192.168.1.80:6447 ...
```

## Flux reconcile pattern
Force immediate reconcile (bypasses poll interval):
```bash
kubectl -n flux-system annotate <kind> <name> \
  reconcile.fluxcd.io/requestedAt="$(date -u +%Y-%m-%dT%H:%M:%SZ)" --overwrite
```

## CC-028 split status
Per-cluster repos created: `gitopsdev-infra`, `gitopsdev-apps`.
Remaining: `gitopsete-infra/apps`, `gitopsprod-infra/apps`, `openclaw-infra/apps`,
`management-infra`, `shared-infra`, `cluster-charts`.
Phase 0 (repo creation + SOPS keys): complete.
Phase 1 (manifest seeding): in progress — see CC-028 in trismagistus-tasks.md.

## Related repos
- `/Users/martincolley/workspace/gitopsdev-apps/` — gitopsdev apps (primary active per-cluster repo)
- `/Users/martincolley/workspace/gitopsapi/` — GitOpsAPI source code
- `/Users/martincolley/workspace/podzoneAgentTeam/` — planning and specs
