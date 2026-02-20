# ShopMicro Production Platform (Capstone)

This repo delivers a reproducible, production-style platform for **ShopMicro**:
- **Frontend**: React (Vite)
- **Backend API**: Node.js/Express
- **ML service**: Python/Flask
- **Data**: PostgreSQL + Redis
- **Platform**: Docker Compose + Kubernetes + Observability (Grafana LGTM + OpenTelemetry)
- **Automation**: Terraform + Ansible + GitHub Actions
- **Ops tooling**: `shopmicroctl` evidence/health CLI

## 1) Problem statement and architecture summary
I am the Platform Engineering team for a microservices e-commerce system. Your goal is to build, deploy, and operate the system using a complete DevOps toolchain: containerization, Kubernetes operations, observability (metrics/logs/traces), IaC/CaC, CI/CD quality gates, security controls, and an operational CLI utility.

## 2) High-level architecture diagram

```
                  ┌─────────────────────────────┐
                  │           Ingress            │
                  │   (Nginx / local ingress)    │
                  └──────────────┬──────────────┘
                                 │
                 ┌───────────────┴────────────────┐
                 │                                │
        ┌────────▼────────┐               ┌───────▼────────┐
        │    Frontend     │               │     Backend     │
        │  React (Vite)   │  REST / JSON  │  Node/Express   │
        └─────────────────┘               └───────┬────────┘
                                                  │
                                       ┌──────────┴──────────┐
                                       │                     │
                                ┌──────▼──────┐      ┌──────▼──────┐
                                │  PostgreSQL │      │    Redis     │
                                │   (PVC)     │      │   (cache)    │
                                └─────────────┘      └─────────────┘

                         ┌─────────────────────────────────────┐
                         │            ML Service               │
                         │     Python/Flask recommendations    │
                         └─────────────────────────────────────┘

Observability:
- OpenTelemetry Collector receives traces/metrics/logs
- Grafana + Loki (logs) + Tempo (traces) + Prometheus/Mimir-compatible (metrics)
```

## 3) Prerequisites and tooling versions
Local (Windows/macOS/Linux):
- Docker Desktop (Linux containers) + Docker Compose v2
- Node.js 20+ (optional if you run frontend outside Docker)
- Python 3.10+ (optional if you run ML service outside Docker)

Kubernetes (choose one):
- **minikube** (recommended for beginners) OR **kind**
- `kubectl` v1.28+
- `helm` v3.13+ (used for ingress and optional LGTM install)

## 4) Exact deploy commands

### A) Local (Docker Compose) — quickest path
1. Start Docker Desktop.
2. From repo root:
```bash
docker compose up --build
```
3. Open:
- Frontend: http://localhost:3000
- Backend health: http://localhost:8080/health
- Backend products: http://localhost:8080/products
- ML health: http://localhost:5000/health
- ML recs: http://localhost:5000/recommendations/42

Optional: run the observability stack locally too:
```bash
docker compose --profile observability up -d
```
Then open:
- Grafana: http://localhost:3001 (user/pass: admin/admin)

### B) Kubernetes (minikube) — production-style
1. Start cluster:
```bash
minikube start
minikube addons enable ingress
```

2. Build images into minikube’s Docker:
```bash
eval $(minikube docker-env)
docker build -t shopmicro-backend:local ./backend
docker build -t shopmicro-ml:local ./ml-service
docker build -t shopmicro-frontend:local ./frontend
```

3. Deploy:
```bash
kubectl apply -k k8s/overlays/local
```

4. Get the ingress URL:
```bash
minikube ip
kubectl -n shopmicro get ingress
```
Add to your hosts file:
- Windows: `C:\Windows\System32\drivers\etc\hosts`
- macOS/Linux: `/etc/hosts`

Example:
```
<MINIKUBE_IP> shopmicro.local
```

Then open:
- http://shopmicro.local

## 5) Exact test/verification commands

### Local quick checks
```bash
curl -s http://localhost:8080/health
curl -s http://localhost:8080/products
curl -s http://localhost:5000/health
curl -s http://localhost:5000/recommendations/42
```

### Kubernetes quick checks
```bash
kubectl -n shopmicro get pods,svc,ingress
kubectl -n shopmicro describe deploy backend
kubectl -n shopmicro logs deploy/backend --tail=50
```

## 6) Observability usage guide (metrics/logs/traces)

Local (compose profile):
- Grafana: http://localhost:3001 (admin/admin)
- Loki/Tempo/Prometheus endpoints are wired via `observability/`

Kubernetes:
- `k8s/observability/` contains OpenTelemetry Collector and a minimal LGTM stack.
- Dashboards are in `observability/dashboards/` (JSON exports).

## 7) Rollback procedure

Kubernetes rollback example (backend):
```bash
kubectl -n shopmicro rollout status deploy/backend
kubectl -n shopmicro rollout undo deploy/backend
kubectl -n shopmicro rollout status deploy/backend
```

To demonstrate rolling update:
- Change image tag in `k8s/overlays/local/kustomization.yaml`
- Apply and then undo.

## 8) Security controls implemented
- Secrets stored in Kubernetes Secret (not hardcoded in Deployment)
- NetworkPolicy to restrict traffic (only required service paths)
- Non-root containers where practical, read-only root filesystem for backend/ml
- Resource requests/limits on workloads

## 9) Backup/restore procedure
PostgreSQL:
- Local: `docker exec -t <postgres_container> pg_dump ... > backup.sql`
- Kubernetes: `kubectl exec` into postgres pod and run `pg_dump`
Runbook: `runbooks/backup-restore.md`

## 10) Known limitations and next improvements
- This repo ships a **local** LGTM stack for learning, not an HA production setup.
- TLS for ingress is documented but not enabled by default (needs cert manager).
- Terraform modules are “realistic structure” and can be pointed to AWS accounts.

---

## Quick helper: one command evidence bundle
```bash
./tools/shopmicroctl.sh evidence
```
This creates `evidence/` outputs (cluster state, curl checks, rollout proof).
-------------------------------------------------------------------------------------------------------------
# ShopMicro – Extra Credit Pack

This is merged into **existing ShopMicro capstone repository**.
It adds extra-credit deliverables: progressive delivery (canary), chaos experiments, security
policies, CI checks, runbooks, and an evidence workflow.

## What you get (high level)
- Canary release manifests (Ingress canary annotations)
- Promotion + rollback workflow
- Chaos Mesh experiments (pod kill + latency)
- NetworkPolicy + Gatekeeper example policy
- Extra-credit CI workflow template
- Runbooks + report template
- Makefile shortcuts + evidence capture

## Quick Start (Kubernetes via Minikube)
Prereqs: Docker Desktop, kubectl, minikube

1) Start cluster + ingress:
```bash
minikube start --driver=docker
minikube addons enable ingress
kubectl config use-context minikube
```

2) Build images **inside** minikube docker:
```bash
eval $(minikube -p minikube docker-env --shell bash)
make build
```

3) Deploy your app (expects your capstone kustomize overlays exist):
```bash
make deploy ENV=dev
```

4) Canary (route 20% to v2) then promote or rollback:
```bash
make canary
make promote
make rollback
```

5) Evidence collection:
```bash
make evidence-pack
```

## How to merge into your repo
Unzip this pack, then copy the folders into your existing repo root:
- k8s/progressive
- chaos
- security
- runbooks
- .github/workflows
- observability
- EXTRA_CREDIT_REPORT.md
- Makefile



