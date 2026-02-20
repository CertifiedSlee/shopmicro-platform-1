# CAPSTONE_REPORT

## What was built
A production-style platform for ShopMicro covering containerization, Kubernetes deployment, observability, IaC/CaC structure, CI/CD quality gates, security controls, runbooks, and an ops CLI.

## Where to look
- Containers: `docker-compose.yml`, `backend/Dockerfile`, `ml-service/Dockerfile`, `frontend/Dockerfile`
- Kubernetes: `k8s/` (kustomize base + local overlay + observability)
- Observability: `observability/` (otel collector + dashboards)
- IaC: `infrastructure/terraform/` modules + `infrastructure/ansible/` roles
- CI/CD: `.github/workflows/`
- Runbooks: `runbooks/`
- Ops tool: `tools/shopmicroctl.sh`
- Evidence: `evidence/` (generated)

## How to demo
1) Local compose: `docker compose up --build`
2) K8s: `minikube start && minikube addons enable ingress`, then `kubectl apply -k k8s/overlays/local`
3) Trigger rollback: `kubectl -n shopmicro rollout undo deploy/backend`
4) Open Grafana (local profile) or port-forward in k8s.
