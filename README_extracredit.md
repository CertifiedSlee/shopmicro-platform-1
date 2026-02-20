# ShopMicro – Extra Credit Pack

This package is designed to be merged into your **existing ShopMicro capstone repository**.
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

Commit and push to GitHub, then submit your repo link.
