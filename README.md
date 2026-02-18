# Apache Spark on Kubernetes Demo

**Guest Session by Rukshan J. Senanayaka**
University of Moratuwa — Faculty of Information Technology
Big Data Module | 18 February 2026, 1:15 pm – 3:15 pm

Demonstrates deploying and running Apache Spark on Kubernetes using the Spark Operator, with a COVID-19 dataset as the workload.

---

## Learning Objectives

1. How Apache Spark distributes computation across executor pods
2. How the Spark Operator manages Spark applications via Kubernetes CRDs
3. The lifecycle of Spark driver and executor pods
4. How to configure and scale Spark workloads declaratively

---

## Architecture

```
Your Mac (host)
└── Docker Desktop
    └── Minikube (single-node Kubernetes cluster)
        ├── Namespace: spark-operator
        │   └── spark-operator-controller   ← watches for SparkApplication CRDs
        └── Namespace: spark-jobs
            ├── covid-analysis-driver       ← orchestrates job, runs Python
            ├── covid-analysis-exec-1       ← executes distributed tasks
            └── covid-analysis-exec-2       ← executes distributed tasks
```

**Key components:**

| Component | Role |
|---|---|
| **Minikube** | Runs a real Kubernetes cluster inside Docker on your laptop |
| **Spark Operator** | Kubernetes controller that turns `SparkApplication` CRDs into pods |
| **Driver Pod** | The coordinator — runs the Python script, spawns executors, collects results |
| **Executor Pods** | Workers — receive tasks from the driver and process data in parallel |
| **SparkApplication CRD** | A custom Kubernetes resource type that declaratively defines a Spark job |

---

## Project Structure

```
ApacheSparkSession/
├── src/
│   └── covid_analysis.py
├── docker/
│   └── Dockerfile
├── kubernetes/
│   └── spark-jobs/
│       ├── namespace.yaml
│       ├── rbac.yaml
│       └── covid-analysis.yaml
├── scripts/
│   ├── reset.sh
│   ├── run-analysis.sh
│   ├── view-spark-ui.sh
│   └── cleanup.sh
└── docs/
    └── HANDS-ON-LAB.md
```

### `src/covid_analysis.py`
The PySpark application. Contains the data loading and all 4 analyses. This is the only file with actual business logic — everything else is infrastructure to get this script running on Kubernetes.

### `docker/Dockerfile`
Packages the Python script into a container image. Kubernetes doesn't run scripts directly — it runs containers. The Dockerfile starts from an official Spark base image, adds `pandas`, and copies the script in. The result is an image called `spark-covid-analysis:latest`.

### `kubernetes/spark-jobs/namespace.yaml`
Creates a Kubernetes namespace called `spark-jobs`. A namespace is just a logical boundary — all the Spark pods live here, separated from Kubernetes system components. It's the equivalent of a folder for resources.

### `kubernetes/spark-jobs/rbac.yaml` — why does this exist?

In Kubernetes, pods don't have any permissions by default. When the Spark **driver** pod starts, one of its first jobs is to call the Kubernetes API to **create the executor pods**. Without permission, that API call would be rejected.

RBAC (Role-Based Access Control) is how you grant that permission. The file defines three things:

1. **ServiceAccount `spark`** — an identity that the driver pod runs as (like a user account, but for a pod)
2. **Role `spark-role`** — a set of allowed actions: create/delete/get pods, services, configmaps, and PVCs in the `spark-jobs` namespace
3. **RoleBinding** — links the ServiceAccount to the Role, so the driver pod (running as `spark`) can perform those actions

Without this file, submitting a job would fail with a `403 Forbidden` error the moment the driver tried to spawn executors.

### `kubernetes/spark-jobs/covid-analysis.yaml`
The `SparkApplication` CRD — the actual job definition. This tells the Spark Operator what image to use, how many executor pods to create, and how much CPU/memory each gets. It references the `spark` ServiceAccount from `rbac.yaml`.

### `scripts/reset.sh`
Resets the Spark environment without destroying the Minikube cluster. Starts Minikube if it isn't running, wipes and recreates the `spark-jobs` namespace and RBAC, installs the Spark Operator if not already present, and rebuilds the Docker image. The Operator and its pulled images are preserved across resets so subsequent runs are fast.

### `scripts/run-analysis.sh`
Submits the `SparkApplication` to Kubernetes and streams the driver pod's logs to your terminal so you can watch the job run.

### `scripts/view-spark-ui.sh`
Port-forwards the Spark web UI (port 4040 inside the driver pod) to `localhost:4040` on your machine, so you can inspect the execution plan in a browser.

### `scripts/cleanup.sh`
Deletes the `SparkApplication` object from Kubernetes (and the pods with it). Leaves the cluster running.

---

## Quick Start

### Prerequisites

- Docker Desktop running
- `minikube`, `kubectl`, `helm` installed

```bash
brew install minikube kubectl helm
```

### Run the demo

```bash
# 1. Full environment setup (takes ~3 min on first run)
./scripts/reset.sh

# 2. Run the analysis and stream logs
./scripts/run-analysis.sh
```

For a guided walkthrough, follow **[docs/HANDS-ON-LAB.md](docs/HANDS-ON-LAB.md)**.

---

## What the Analysis Does

The PySpark app (`src/covid_analysis.py`) fetches COVID-19 data from a public GitHub dataset and runs 4 analyses:

1. Top 10 countries by total confirmed cases
2. Top 10 countries by total deaths
3. Global totals (confirmed, deaths, recovered)
4. Dataset summary (198 countries, 161,568 records)

**Spark concepts demonstrated:** DataFrame API, `groupBy`/`agg`/`orderBy`, distributed aggregation, Catalyst query optimizer, Adaptive Query Execution.

---

## Key Kubernetes Concepts

### Namespace

`spark-jobs` is a logical partition in the cluster. All Spark pods run here, isolated from system components.

### RBAC

The driver pod needs to create and delete executor pods at runtime. The `spark` ServiceAccount is granted that permission via a `Role` and `RoleBinding`.

### SparkApplication CRD

The Spark Operator installs a new Kubernetes resource type. Instead of defining a `Deployment`, you define a `SparkApplication`:

```yaml
kind: SparkApplication
spec:
  driver:
    cores: 1
    memory: "512m"
  executor:
    instances: 2   # Change this number to scale
    cores: 1
    memory: "512m"
```

### Docker image in Minikube

`reset.sh` runs `eval $(minikube docker-env)` before building. This points the Docker CLI at Minikube's internal daemon, so the image is available inside the cluster without a registry. `imagePullPolicy: Never` in the YAML ensures Kubernetes uses that local image.

---

## Monitoring

```bash
# Check job status
kubectl get sparkapplication -n spark-jobs

# Check pods
kubectl get pods -n spark-jobs

# Stream driver logs
kubectl logs -f covid-analysis-driver -n spark-jobs

# Spark UI (only while driver is running)
./scripts/view-spark-ui.sh
# → http://localhost:4040
```

---

## Cleanup

```bash
# Remove the Spark job only (keeps cluster running)
./scripts/cleanup.sh

# Stop Minikube (preserves the cluster for next time)
minikube stop

# Delete everything
minikube delete
```

---

## Why Spark on Kubernetes?

| Advantage | Explanation |
|---|---|
| Dynamic scaling | Executor count can change per job |
| Multi-tenancy | Multiple Spark jobs run in isolated namespaces |
| Declarative | Jobs are defined as Kubernetes resources (CRDs) |
| Cloud-native | Reuse the same K8s tooling for monitoring, logging, autoscaling |
