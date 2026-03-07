# openclaw-with-brain — Deep Dive

> Helm chart by **filipegalo** · Current version: **v0.1.20** · [Artifact Hub](https://artifacthub.io/packages/helm/openclaw-with-brain/openclaw-with-brain)

---

## What It Is

A Helm chart specifically designed for deploying OpenClaw with a **git-backed brain repository**. It provides an AI agent gateway with bidirectional workspace and config synchronisation, an optional Chromium sidecar, GitHub CLI pre-installed, and read-only Kubernetes cluster access via ClusterRole.

This is the chart most aligned with git-sync workflows, as git synchronisation is a first-class concern in its design — not bolted on.

---

## Architecture Overview

The chart deploys several components working together:

### 1. Core OpenClaw Gateway
The main agent process running on port `18789`, handling messaging integrations and agent execution. The Gateway is the interface layer — it handles connections to messaging platforms like Telegram, Discord, or Slack, managing incoming messages and routing them to core logic. This decouples the interface from the intelligence, allowing you to talk to your agent from anywhere.

### 2. Bidirectional Git Sync
The chart's headline feature. Unlike a simple `git pull` on startup, it provides *bidirectional* sync — meaning changes made by the agent at runtime (new memories, updated workspace files) are pushed back to the remote brain repository, and external changes to the repo are pulled in. This is the mechanism that enables shared context across multiple agent instances.

### 3. Optional Chromium Sidecar
A headless browser that connects to the agent via Chrome DevTools Protocol (CDP), enabling browser automation tasks without requiring a separate deployment.

### 4. GitHub CLI (`gh`)
Pre-baked into the image, allowing the agent to interact with GitHub repositories directly — creating issues, PRs, pushing branches — as part of automated workflows.

### 5. Read-only ClusterRole
A ClusterRole is provisioned giving the agent read-only access to the Kubernetes cluster, so it can introspect workloads, services, and pod status without being able to modify cluster state. Useful for DevOps-oriented agents.

---

## Why This Chart Fits a Git-Sync Workflow

Since bidirectional git synchronisation between agent contexts is already in use, `openclaw-with-brain` operationalises this at the infrastructure level rather than requiring custom scripting. Key benefits:

- **Shared brain across agents**: Because workspace and config are synced to a git repo, multiple OpenClaw instances (e.g. a dev instance and a prod instance) can share the same accumulated memory, instructions, and skills — with git as the source of truth and conflict resolution layer.
- **Persistence across pod restarts**: When a pod is replaced (upgrade, eviction, node failure), the init container clones the brain repo fresh, so no state is lost to ephemeral storage.
- **Auditability**: Every change the agent makes to its own workspace is a git commit — you get a full history of what the agent wrote, learned, or modified.

---

## Relevant Skills That Complement This Chart

The OpenClaw skill ecosystem has several skills built specifically for git-backed memory patterns that pair well with this chart:

| Skill | Purpose |
|---|---|
| `brainrepo` | Personal knowledge repository for capturing, organising, and retrieving information |
| `claw-roam` | Syncs an OpenClaw workspace between multiple machines |
| `context-anchor` | Recovers from context compaction by scanning memory files |
| `continuity` | Handles asynchronous reflection and memory integration for persistent AI context |

---

## Installation

```bash
helm repo add openclaw-with-brain https://filipegalo.github.io/openclaw-with-brain
helm repo update

helm install openclaw openclaw-with-brain/openclaw-with-brain \
  -n openclaw \
  -f values.yaml
```

### SSH Deploy Key Secret

Before installing, create the Kubernetes secret containing your git deploy key:

```bash
kubectl create secret generic openclaw-ssh-key \
  -n openclaw \
  --from-file=id_rsa=/path/to/deploy_key \
  --from-file=id_rsa.pub=/path/to/deploy_key.pub
```

---

## Considerations & Caveats

### Git Conflict Management
Bidirectional sync means write conflicts are possible if two agents commit to the same branch simultaneously. If running multiple instances, consider a **branch-per-agent** strategy and using PRs to merge brain states.

### Security
When running an autonomous agent on your local network, security is critical. OpenClaw is powerful, which means it can be dangerous if misconfigured. Always follow the Principle of Least Privilege — only map the directories the agent absolutely needs, and never map your home directory or SSH keys. Use Human-in-the-Loop settings to require manual approval for sensitive tool calls like shell execution or file writes.

### Fake Repository Warning
There have been fake OpenClaw GitHub repositories being promoted via search engines, used to push info-stealing malware. Always install from the verified `filipegalo/openclaw-with-brain` Artifact Hub listing and confirm the repo URL before adding it.

### Chart Maturity
At v0.1.20 this is still early-stage. The rapid versioning (20 patch releases) suggests active development but also means the API surface is still evolving — **pin your version in production**.

---

## See Also

- [Artifact Hub listing](https://artifacthub.io/packages/helm/openclaw-with-brain/openclaw-with-brain)
- [openclaw-with-brain GitHub](https://github.com/filipegalo/openclaw-with-brain)
- [OpenClaw documentation](https://openclaw.ai/docs)