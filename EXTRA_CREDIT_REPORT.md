# Extra Credit Report – ShopMicro

> Fill this with your real screenshots + outputs after you run the steps.

## 1. Initial vs. Improved Architecture
**Initial state (capstone):**
- Single environment (or minimal overlays)
- Basic deployment via Docker Compose / K8s manifests
- Limited release safety controls

**Improved state (extra credit):**
- Dev/Staging/Prod overlays (or at least Dev + Prod)
- Canary release for backend API (progressive traffic shift)
- Rollback procedure with proof
- Chaos testing to validate resiliency
- Security controls (NetworkPolicy + policy enforcement template)
- CI checks for policy + scanning (template)
- Evidence automation

## 2. Release Strategy (Canary)
We choose **canary** to reduce blast radius:
- Start with 10–20% traffic to v2
- Observe SLOs (error rate, latency, availability)
- Promote to 100% if healthy; rollback if unhealthy

## 3. Automated Promotion / Rollback Rules
Suggested gates (update with your numbers):
- HTTP 5xx rate < 1%
- p95 latency < 500ms
- Availability > 99.9%

Rollback trigger examples:
- Error rate above threshold for N minutes
- Pods crash looping
- Health checks failing

## 4. Chaos Experiments
### Experiment A: Pod Kill (backend)
Goal: validate restart + recovery behavior under failure.

### Experiment B: Network Latency (ml-service)
Goal: validate graceful degradation when dependency is slow.

## 5. Chaos Results
Fill in after running:
- MTTD (time to detect)
- MTTR (time to recover)
- Error budget impact

Attach:
- `evidence/chaos-podkill.txt`
- `evidence/chaos-latency.txt`
- screenshots of pods recovering / metrics

## 6. Security Controls
Implemented:
- NetworkPolicy limiting backend ingress to frontend (example)
- Gatekeeper constraint template requiring labels

Explain:
- What traffic is allowed/blocked
- What policy is enforced
- How violations are detected

## 7. Cost / Capacity Optimization
Document:
- requests/limits tuning
- HPA configuration (if present in your capstone overlays)
- Expected impact

Attach:
- `evidence/k8s-top.txt` (optional)
- HPA screenshots/outputs

## 8. Risks & Future Improvements
- Wire real SLO alerts in Grafana
- Add service mesh for advanced traffic shaping
- Replace templates with real Trivy + Conftest + Gatekeeper library constraints
