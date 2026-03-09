# Requirements: OpenClaw Application Deployment

## Current Status
The `openclaw` cluster is provisioned and Flux is reconciling successfully, but the OpenClaw application itself is not deploying due to a missing Helm repository.

## Problem
The HelmRelease in `gitops/gitops-apps/openclaw/openclaw.yaml` references:
```yaml
url: https://charts.openclaw.ai/
```

This URL does not exist. OpenClaw does not currently publish a public Helm chart repository.

**Error from cluster:**
```
failed to fetch Helm repository index: Get "https://charts.openclaw.ai/index.yaml": 
dial tcp: lookup charts.openclaw.ai on 10.96.0.10:53: no such host
```

## Deployment Options

### Option 1: Raw Kubernetes Manifests
Deploy OpenClaw using standard Kubernetes YAML manifests directly in the GitOps repository.

**Pros:**
- Full control over configuration
- No external dependencies
- Easy to customize

**Cons:**
- More verbose than Helm
- Manual updates required
- Harder to manage across environments

### Option 2: Local Helm Chart
Create a custom Helm chart in the cluster09 repository for OpenClaw.

**Pros:**
- Templating and value override support
- Easier to manage environment differences
- Standard Kubernetes packaging

**Cons:**
- Need to maintain chart ourselves
- Updates require chart version bumps

### Option 3: Wait for Official Helm Chart
OpenClaw may publish an official chart in the future.

**Pros:**
- Official support
- Regular updates

**Cons:**
- Unknown timeline
- Blocks current deployment

## Recommended Approach
**Option 2: Create a local Helm chart** in `charts/openclaw/` with the following structure:

```
charts/openclaw/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   ├── secret.yaml (SOPS encrypted)
│   └── ingress.yaml (HTTPRoute)
```

Then update the HelmRelease to use a local chart source:
```yaml
chart:
  spec:
    chart: charts/openclaw
    sourceRef:
      kind: GitRepository
      name: flux-system
```

## Required Information
To create the chart, we need:
1. OpenClaw container image and tag
2. Required environment variables and config
3. Port configuration
4. Resource requirements
5. Persistent volume needs (if any)
6. Service account/RBAC requirements

## Next Steps
1. Document OpenClaw deployment requirements
2. Create initial Helm chart structure
3. Test deployment in openclaw cluster
4. Update gitops manifests to use local chart
5. Document deployment process in cluster09 docs

---
*Assigned to: 🧠 Claude Code*  
*Priority: High (blocks openclaw application deployment)*  
*Status: Blocked - need OpenClaw deployment specs*
