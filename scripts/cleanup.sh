#!/bin/bash

echo "=============================================================================="
echo "  Cleaning Up Spark Resources"
echo "=============================================================================="
echo ""

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Delete SparkApplication
print_status "Deleting SparkApplication..."
kubectl delete sparkapplication --all -n spark-jobs --ignore-not-found=true
print_success "SparkApplication deleted"

# Wait for pods to terminate
print_status "Waiting for pods to terminate..."
kubectl wait --for=delete pods --all -n spark-jobs --timeout=60s 2>/dev/null || true
print_success "All pods terminated"

# Show status
echo ""
echo "Current status:"
kubectl get all -n spark-jobs

echo ""
print_success "Cleanup complete!"
echo ""
echo "To delete everything (including operator):"
echo "  kubectl delete namespace spark-operator spark-jobs"
echo ""
echo "To stop Minikube:"
echo "  minikube stop"
echo ""
