Good question — RAG on Kubernetes requires a few additional components on top of OpenClaw and Ollama. Let me search for the current state of the recommended stack.Good — I now have what I need. Here's the recommended RAG Helm chart stack for OpenClaw + Ollama on Kubernetes.

---

## RAG Helm Charts for OpenClaw + Ollama on Kubernetes

A full RAG stack requires three additional layers on top of OpenClaw and Ollama: an **embedding model**, a **vector database**, and optionally a **document ingestion pipeline**. Everything below is self-hosted and keeps data fully on-prem.

---

### 1. Vector Database — Qdrant *(recommended)*

Qdrant is particularly well-suited for on-premise/air-gapped Kubernetes deployments, with strong support for complex filtering and hybrid search. It's written in Rust, has a clean REST API, and integrates natively with Ollama embeddings.

The latest official Qdrant Helm chart version is **1.17.0**, tracking Qdrant app version v1.17.0.

```bash
helm repo add qdrant https://qdrant.github.io/qdrant-helm
helm repo update
helm upgrade -i qdrant qdrant/qdrant \
  --namespace vector \
  --create-namespace \
  -f qdrant-values.yaml
```

A minimal production-ready `qdrant-values.yaml`:

```yaml
replicaCount: 3
persistence:
  enabled: true
  size: 30Gi
resources:
  requests:
    memory: "2Gi"
    cpu: "500m"
  limits:
    memory: "4Gi"
    cpu: "1000m"
podDisruptionBudget:
  enabled: true
  maxUnavailable: 1
```

> **Note:** While distributed mode is possible with the Helm chart, it does not provide the same zero-downtime upgrade, autoscaling, or backup/disaster recovery features as Qdrant's enterprise operator. Community support only applies to this chart.

---

### 2. Embeddings — via Ollama (no extra chart needed)

Since you already have Ollama running, you can use it directly for embeddings — no separate chart required. Pull a dedicated embedding model:

```bash
# Inside your Ollama deployment
ollama pull nomic-embed-text   # lightweight, 768 dimensions
# or
ollama pull mge-m3             # multilingual, higher quality, 1024 dimensions
```

Point your RAG pipeline at the in-cluster Ollama service:
```
http://ollama.ollama.svc.cluster.local:11434
```

---

### 3. Document Ingestion / RAG Orchestration

You need something to chunk documents, generate embeddings, store them in Qdrant, and handle retrieval at query time. Two good options:

**Option A: Anything LLM** — if OpenClaw doesn't have built-in RAG ingestion UI, AnythingLLM provides a web interface for uploading and managing documents with Qdrant and Ollama support. Check Artifact Hub for community charts.

**Option B: Build your own ingestion job** using a simple Kubernetes `Job` or `CronJob` with LangChain or LlamaIndex, pointing at Ollama for embeddings and Qdrant for storage. This is the most common pattern for production:

```yaml
# Example CronJob skeleton for re-ingestion
apiVersion: batch/v1
kind: CronJob
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: ingest
            image: your-ingest-image
            env:
            - name: OLLAMA_BASE_URL
              value: "http://ollama.ollama.svc.cluster.local:11434"
            - name: QDRANT_URL
              value: "http://qdrant.vector.svc.cluster.local:6333"
```

---

### Summary Table

| Component | Helm Chart | Version | Repo |
|---|---|---|---|
| OpenClaw | `openclaw/openclaw` | 1.3.22 | `https://serhanekicii.github.io/openclaw-helm` |
| Ollama | `otwld/ollama` | latest | `https://helm.otwld.com/` |
| Vector DB | `qdrant/qdrant` | **1.17.0** | `https://qdrant.github.io/qdrant-helm` |
| Embeddings | via Ollama | — | (no extra chart) |

---

### How they wire together

```
User → OpenClaw
         ↓
    Query embedding (Ollama: nomic-embed-text)
         ↓
    Vector search (Qdrant)
         ↓
    Retrieved context chunks
         ↓
    Generation (Ollama: e.g. llama3)
         ↓
    Response → User
```

All traffic stays in-cluster over Kubernetes DNS — no data leaves your infrastructure.
