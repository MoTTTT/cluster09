# Prompts Log

A timestamped record of prompts and instructions from Martin.

---

## 2026-03-07

### 10:48 GMT (2026-03-08)
**Request**: Please use the non-replicated storage, I still need to understand the issue with the replicated

### 10:36 GMT (2026-03-08)
**Question**: Functional questions regarding a similar tool (Klances - Kubernetes read-only UI)

### 13:50 GMT (2026-03-07)
**Greeting**: Hi

### 04:52 GMT
**Report**: Changes pushed

### 03:36 GMT
**Report**: Awesome, pushed

### 03:31 GMT
**Request**: We need to set StorageClass probably. Please use the replicated one (piraeus-storage-replicated)

### 03:29 GMT
**Request**: Please add task Task: Note the documentation in docs/AddingClusters.md and AddingApplications.md, and propose refinements in the instructions based on what we have leared.

### 02:57 GMT
**Report**: There is still a recnciliation issue in the kustomizations

### 00:28 GMT
**Request**: Please add the following tasks to the plan:
- a gitops/gitops-apps/ollama using the helm repo https://helm.otwld.com/, and the chart otwld/ollama, Version: latest
- a gitops/gitops-apps/qdrant, https://qdrant.github.io/qdrant-helm, qdrant/qdrant, V1.17.0
- See /planning/RAMRecommendation.md

### 00:26 GMT
**Request**: CPU Utilisation is very low on ollama

---

## 2026-03-06

### 23:56 GMT
**Request**: Allama has 42 CPUs and 64GB RAM. We're using 16GB RAM. CPU usage spiked at less than 4% for 5 mins. Can we run multiple models, and compare their performance. Did you manage to get any jobs completed on ollama?

### 17:44 GMT
**Request**: Please prioritise delegation of tasks to ollama, so prepared to focus on that for now. I'm not seeing resource utilisation on the olama installation. Please purge the model and get a few jobs through the pipeline.

### 17:41 GMT
**Request**: Please have a look at cluster09/planning/OpenclawHelmChartSelection.md, and a values.yaml file recomendation from claud

### 17:28 GMT
**Request**: What's with the cyrillic security marketing?

### 17:27 GMT
**Report**: API Balance is US$18.71

---

## 2026-03-05

### 18:51 GMT
**Request**: I am stepping away for a couple of hours, so please continue with the batched work, and any preparation for the next session. Also look into migrating planning and agent workflows out of cluster09, to a repo called agentsync

### 18:51 GMT
**Request**: Add to backlog: periodically rebuild and publish cluster09 mkdocs site

### 17:55 GMT
**Request**: Cool. It may be better to use a directory such as /planning to put the changelog.md file, as /docs is used for a mkdocs site.

### 17:52 GMT
**Request**: Hi. Please update cluster09/Planning.md with all the tasks discussed since the last update.

---

## 2026-03-04

### 19:11 GMT
**Feedback**: Instruction for bootstrapping flux for new cluster has been upgraded, without the related documentation updates: manifests for cluster gitpos repo url and credentials are loaded in talos ExtraManifests. I need to check, but I think the only action is to load the SOPS key into the new cluster. Flux finds this on the next recon, and pulls the workload kustomizations.

### 19:06 GMT
**Request**: Are you able to see Telegram chat history?

### 19:04 GMT
**Request**: Please check the chat history for prompts that may have been missed due to throttling, e.g.: the remaining .kube/config cleanup. Are you able to see these prompts?

### 19:04 GMT
**Request**: Hi. Please check the last three requests and update planning
