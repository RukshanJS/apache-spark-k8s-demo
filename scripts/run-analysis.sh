#!/bin/bash
set -e

echo "=============================================================================="
echo "  Running COVID-19 Analysis with Apache Spark"
echo "=============================================================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Clean up any previous run
print_status "Cleaning up previous runs..."
kubectl delete sparkapplication covid-analysis -n spark-jobs --ignore-not-found=true
sleep 2

# Apply SparkApplication
print_status "Submitting Spark application..."
kubectl apply -f kubernetes/spark-jobs/covid-analysis.yaml
print_success "SparkApplication submitted"

# Wait for driver pod to be created
print_status "Waiting for driver pod to start..."
sleep 5

# Get driver pod name
DRIVER_POD=""
for i in {1..30}; do
    DRIVER_POD=$(kubectl get pods -n spark-jobs -l spark-role=driver -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    if [ -n "$DRIVER_POD" ]; then
        break
    fi
    echo "Waiting for driver pod... ($i/30)"
    sleep 2
done

if [ -z "$DRIVER_POD" ]; then
    echo "Error: Driver pod not found"
    exit 1
fi

print_success "Driver pod found: $DRIVER_POD"

# Stream logs
echo ""
echo "=============================================================================="
echo "  Streaming Driver Logs (Ctrl+C to exit)"
echo "=============================================================================="
echo ""

kubectl logs -f "$DRIVER_POD" -n spark-jobs

echo ""
print_success "Analysis complete!"
echo ""
echo "To view application status:"
echo "  kubectl get sparkapplication -n spark-jobs"
echo ""
echo "To view all pods:"
echo "  kubectl get pods -n spark-jobs"
echo ""
