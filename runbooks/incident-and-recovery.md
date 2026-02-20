# Incident + Recovery Runbook (Extra Credit)

## Scenario: Backend errors spike after a new release
1) Confirm alert is real (check Grafana dashboard and recent deploys)
2) Identify scope (which routes/users, which version)
3) Immediate mitigation:
   - reduce canary weight to 0% OR rollback deployment
4) Validate recovery:
   - health endpoints OK
   - error rate back to baseline
5) Post-incident:
   - root cause
   - prevention action items

## Commands
Rollback:
```bash
kubectl -n shopmicro rollout undo deploy/backend
kubectl -n shopmicro rollout status deploy/backend
```

Check pods:
```bash
kubectl -n shopmicro get pods -o wide
kubectl -n shopmicro describe pod <pod>
kubectl -n shopmicro logs <pod>
```
