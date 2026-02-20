up:
	docker compose up --build

down:
	docker compose down -v

obs:
	docker compose --profile observability up -d

k8s-apply:
	kubectl apply -k k8s/overlays/local

k8s-delete:
	kubectl delete -k k8s/overlays/local

evidence:
	./tools/shopmicroctl.sh evidence
