# Chaos Experiments (Templates)

These manifests assume Chaos Mesh is installed in your cluster.
If you don't have it, keep these as deliverables + run the equivalent manual tests:
- kill a pod: `kubectl delete pod <backend-pod> -n shopmicro`
- add latency (manual): `tc qdisc` inside a privileged pod or use a service mesh fault injection.

Evidence suggestion:
- capture outputs into `evidence/chaos-*.txt`
