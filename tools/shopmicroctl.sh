#!/usr/bin/env bash
set -euo pipefail

CMD="${1:-help}"

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
evidence_dir="$root_dir/evidence"
mkdir -p "$evidence_dir"

health_local() {
  echo "[health] local endpoints"
  curl -sS http://localhost:8080/health | tee "$evidence_dir/local_backend_health.json" >/dev/null
  curl -sS http://localhost:5000/health | tee "$evidence_dir/local_ml_health.json" >/dev/null
  curl -sS http://localhost:8080/products | tee "$evidence_dir/local_products.json" >/dev/null
  curl -sS http://localhost:5000/recommendations/42 | tee "$evidence_dir/local_recs.json" >/dev/null
  echo "ok"
}

evidence_k8s() {
  echo "[evidence] kubernetes state"
  kubectl -n shopmicro get all -o wide | tee "$evidence_dir/k8s_get_all.txt" >/dev/null
  kubectl -n shopmicro get ingress -o yaml | tee "$evidence_dir/k8s_ingress.yaml" >/dev/null
  kubectl -n shopmicro rollout status deploy/backend | tee "$evidence_dir/k8s_rollout_backend.txt" >/dev/null || true
}

case "$CMD" in
  health) health_local ;;
  evidence)
    {
      date
      echo "=== docker compose ps ==="
      docker compose ps
    } | tee "$evidence_dir/compose_status.txt" >/dev/null || true
    health_local || true
    evidence_k8s || true
    echo "evidence written to: $evidence_dir"
    ;;
  help|*)
    cat <<EOF
Usage: ./tools/shopmicroctl.sh <command>

Commands:
  health     Run local health checks (curl)
  evidence   Collect evidence (compose + curl + k8s if available)
EOF
    ;;
esac
