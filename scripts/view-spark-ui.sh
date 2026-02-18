#!/bin/bash

echo "=============================================================================="
echo "  Accessing Spark UI"
echo "=============================================================================="
echo ""

# Get driver pod name
DRIVER_POD=$(kubectl get pods -n spark-jobs -l spark-role=driver -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")

if [ -z "$DRIVER_POD" ]; then
    echo "Error: No driver pod found. Is the Spark application running?"
    echo ""
    echo "To start the analysis, run:"
    echo "  ./scripts/run-analysis.sh"
    exit 1
fi

echo "Driver pod: $DRIVER_POD"
echo ""
echo "Setting up port-forward to Spark UI..."
echo "Spark UI will be available at: http://localhost:4040"
echo ""
echo "Press Ctrl+C to stop port forwarding"
echo "=============================================================================="
echo ""

# Port forward to Spark UI
kubectl port-forward "$DRIVER_POD" 4040:4040 -n spark-jobs
