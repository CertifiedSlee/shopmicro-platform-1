ENV ?= dev
NAMESPACE ?= shopmicro

bootstrap:
	minikube start --driver=docker
	minikube addons enable ingress
	kubectl config use-context minikube

build:
	docker build -t shopmicro-backend:local ./backend
	docker build -t shopmicro-ml:local ./ml-service
	docker build -t shopmicro-frontend:local ./frontend

deploy:
	kubectl apply -k k8s/overlays/$(ENV)

# Apply canary ingress (20% to v2 service)
canary:
	kubectl apply -f k8s/progressive/canary-ingress.yaml

# Promote canary to 100%
promote:
	kubectl apply -f k8s/progressive/canary-promote.yaml

rollback:
	kubectl -n $(NAMESPACE) rollout undo deploy/backend

smoke-test:
	kubectl -n $(NAMESPACE) get pods,svc,ingress -o wide

evidence-pack:
	mkdir -p evidence
	kubectl -n $(NAMESPACE) get pods,svc,ingress -o wide > evidence/k8s-get.txt
	kubectl -n $(NAMESPACE) rollout history deploy/backend > evidence/rollout-history.txt
