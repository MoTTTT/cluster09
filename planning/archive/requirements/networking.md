# Requirements: Networking & Gateway Configuration

## Problem
The `openclaw` cluster needs external access via `thoth.podzone.cloud` to serve the OpenClaw Gateway API and web interface.

## Current State
- Cluster nodes are up and Ready
- Flux is reconciling infrastructure successfully
- Gateway API manifests exist at `gitops/gitops-gateway/openclaw/openclaw-gateway.yaml`
- DNS resolution within cluster is failing (can't resolve external domains like `charts.openclaw.ai`)

## Goals
1. **Internal DNS**: Ensure cluster can resolve external domains (CoreDNS configuration or upstream DNS servers).
2. **Gateway API**: Configure Cilium Gateway for HTTPS termination.
3. **HTTPRoute**: Route `thoth.podzone.cloud` traffic to OpenClaw service.
4. **External DNS**: Create Cloudflare DNS A record pointing `thoth.podzone.cloud` to cluster ingress IP.
5. **TLS Certificates**: Configure cert-manager with Let's Encrypt for automatic cert provisioning.
6. **Bastion Access**: Ensure SSH bastion can reach the cluster for administrative tasks.

## Architecture

### DNS Flow
```
User → thoth.podzone.cloud (Cloudflare DNS)
  ↓
Cluster Ingress IP (192.168.4.178 or 192.168.4.179 from LoadBalancer pool)
  ↓
Cilium Gateway (kube-system namespace)
  ↓
HTTPRoute → OpenClaw Service (openclaw namespace)
  ↓
OpenClaw Pod(s)
```

### Internal DNS (CoreDNS)
The cluster needs to resolve external domains for:
- Fetching Helm charts (charts.openclaw.ai)
- Let's Encrypt ACME challenges
- External API calls from workloads

**Solution**: Configure CoreDNS to forward to upstream DNS servers (e.g., 1.1.1.1, 8.8.8.8).

### Gateway API Components
1. **GatewayClass**: `cilium` (provided by Cilium CNI)
2. **Gateway**: 
   - Listener on port 80 (HTTP, redirect to HTTPS)
   - Listener on port 443 (HTTPS with TLS termination)
   - TLS certificate from cert-manager
3. **HTTPRoute**: Route `thoth.podzone.cloud` to `openclaw/main:80` service
4. **ClusterIssuer**: Let's Encrypt for automatic TLS cert provisioning

### LoadBalancer IP Allocation
From `openclaw` cluster IP allocation:
- **LB Pool**: `192.168.4.178-179` (2 IPs for services)
- Gateway should receive an IP from this range via MetalLB or Cilium LoadBalancer

## Dependencies
- **Cilium**: Already installed (infrastructure reconciled by Flux)
- **cert-manager**: Check if deployed in infrastructure kustomizations
- **MetalLB or Cilium LoadBalancer**: Verify configuration for IP pool

## Acceptance Criteria
- [ ] Cluster can resolve external domains (test with `nslookup charts.openclaw.ai` from a pod)
- [ ] Gateway resource exists and has an external IP assigned
- [ ] HTTPRoute is bound to Gateway
- [ ] TLS certificate is issued and valid for `thoth.podzone.cloud`
- [ ] `https://thoth.podzone.cloud` is accessible from external network
- [ ] HTTP redirects to HTTPS
- [ ] Let's Encrypt auto-renewal is configured

## Tasks Breakdown
1. **CoreDNS Configuration** (🦉 OpenClaw)
   - Check current CoreDNS ConfigMap
   - Add upstream DNS forwarders if missing
   - Verify external DNS resolution from test pod

2. **Gateway Infrastructure** (🧠 Claude Code)
   - Verify cert-manager is deployed
   - Verify LoadBalancer IP pool configuration
   - Check Gateway and HTTPRoute manifests in `gitops/gitops-gateway/openclaw/`
   - Add ClusterIssuer for Let's Encrypt if missing

3. **DNS Records** (🦉 OpenClaw)
   - Get Gateway external IP (once assigned)
   - Create Cloudflare A record: `thoth.podzone.cloud → <Gateway IP>`

4. **Verification** (🦉 OpenClaw)
   - Test HTTPS access from external network
   - Verify TLS certificate validity
   - Check HTTP → HTTPS redirect

## Risks
- **DNS propagation delay**: Cloudflare updates may take minutes to propagate
- **Let's Encrypt rate limits**: Be careful with cert issuance retries (max 5 per week per domain)
- **LoadBalancer IP exhaustion**: Only 2 IPs available in pool (sufficient for Gateway + one other service)

## References
- Gateway API manifests: `gitops/gitops-gateway/openclaw/openclaw-gateway.yaml`
- Observability cluster example: `gitops/gitops-gateway/managed-observability/observability-gateway.yaml`
- Cilium Gateway documentation: https://docs.cilium.io/en/stable/network/servicemesh/gateway-api/
- cert-manager documentation: https://cert-manager.io/docs/

---
*Assigned to: 🧠 Claude Code (implementation) + 🦉 OpenClaw (coordination)*  
*Priority: 🔴 Critical (blocks OpenClaw application deployment)*
