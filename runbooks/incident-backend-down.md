# Incident Runbook: Backend API down

## Symptoms
- Frontend loads but products list is empty
- `/health` on backend fails or returns 5xx

## Immediate actions
1. Confirm scope:
```bash
kubectl -n shopmicro get pods
kubectl -n shopmicro logs deploy/backend --tail=200
```
2. Check dependencies:
```bash
kubectl -n shopmicro get pods -l app=postgres
kubectl -n shopmicro get pods -l app=redis
```

## Recovery
- If rollout caused it:
```bash
kubectl -n shopmicro rollout undo deploy/backend
```
- If DB credentials wrong: update Secret and restart deployment.

## Post-incident
- Capture evidence via:
```bash
./tools/shopmicroctl.sh evidence
```
