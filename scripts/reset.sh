#!/bin/bash
set -e

echo "============================================"
echo "  Reset — Spark on Kubernetes"
echo "============================================"

GREEN='\033[0;32m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
ok()  { echo -e "${GREEN}✓${NC} $1"; }
run() { echo -e "${BLUE}==>${NC} $1"; }

# ── Step 1: Ensure Minikube is running ──────────────────────────
if minikube status --format='{{.Host}}' 2>/dev/null | grep -q "Running"; then
    ok "Minikube already running — skipping start"
else
    run "Starting Minikube cluster..."
    minikube start --cpus=4 --memory=8192 --driver=docker
    ok "Cluster ready"
fi

# ── Step 2: Clean spark-jobs namespace (wipes all jobs and pods) ─
run "Cleaning spark-jobs namespace..."
kubectl delete namespace spark-jobs --ignore-not-found=true
kubectl wait --for=delete namespace/spark-jobs --timeout=60s 2>/dev/null || true
ok "Namespace cleared"

# ── Step 3: Recreate namespace and RBAC ─────────────────────────
run "Creating namespace and RBAC..."
kubectl apply -f kubernetes/spark-jobs/namespace.yaml
kubectl apply -f kubernetes/spark-jobs/rbac.yaml
ok "Namespace and RBAC ready"

# ── Step 4: Ensure Spark Operator is installed ──────────────────
if helm status spark-operator -n spark-operator &>/dev/null; then
    ok "Spark Operator already installed — skipping"
else
    run "Installing Spark Operator via Helm..."
    helm repo add spark-operator https://kubeflow.github.io/spark-operator --force-update 2>/dev/null
    helm install spark-operator spark-operator/spark-operator \
        --namespace spark-operator \
        --create-namespace \
        --set spark.jobNamespaces="{spark-jobs}"
    run "Waiting for Spark Operator..."
    kubectl wait --for=condition=available deployment/spark-operator-controller \
        -n spark-operator --timeout=300s
    ok "Spark Operator running"
fi

# ── Step 5: Rebuild Docker image ────────────────────────────────
run "Building Docker image..."
eval $(minikube docker-env)
docker build -q -t spark-covid-analysis:latest -f docker/Dockerfile .
ok "Docker image built"

echo ""
echo "============================================"
ok "Ready! Run the demo with:"
echo "   ./scripts/run-analysis.sh"
echo "============================================"
