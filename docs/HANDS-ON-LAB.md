# Hands-On Lab: Apache Spark on Kubernetes

**University of Moratuwa — Big Data Analytics**

> Architecture and concept explanations are in [README.md](../README.md). This guide is purely for following along during the session.

---

## Prerequisites check

Run these before starting. All four must return a version number.

```bash
docker --version
minikube version
kubectl version --client
helm version
```

Also confirm **Docker Desktop is running**.

---

## Part 1 — Read the code (before running anything)

Understanding what we're deploying makes the logs meaningful when we see them.

### 1a. The PySpark application — `src/covid_analysis.py`

Find the three key ideas:

```python
# Entry point — always how a Spark job starts
spark = SparkSession.builder.appName("COVID-19 Analysis").getOrCreate()

# Data loading — pandas fetches CSV on the driver, then Spark distributes it
pandas_df = pd.read_csv(data_url)        # runs on driver only
df = spark.createDataFrame(pandas_df)   # now distributed across executors

# Distributed aggregation — this runs in parallel across all executor pods
top_cases = df.groupBy("Country") \
    .agg(_max("Confirmed").alias("Total_Confirmed")) \
    .orderBy(desc("Total_Confirmed")) \
    .limit(10)
```

**Q:** Why do we load via pandas first instead of Spark reading the CSV directly?
> Spark can read from HTTPS only with additional configuration and libraries. For this demo, it's simpler and more predictable to let the driver download the file with pandas, then distribute it to executors as a Spark DataFrame.

### 1b. The job definition — `kubernetes/spark-jobs/covid-analysis.yaml`

This is the `SparkApplication` CRD. Note the three key fields:

```yaml
image: spark-covid-analysis:latest   # Docker image we'll build
imagePullPolicy: Never               # Use local Minikube image, not DockerHub

driver:
  serviceAccount: spark              # Uses RBAC we set up — allows it to create executor pods

executor:
  instances: 2                       # Creates 2 worker pods
```

---

## Part 2 — Set up the environment

`reset.sh` automates the full environment setup. Run it and watch what each step does.

```bash
./scripts/reset.sh
```

When prompted, type `yes`.

The script runs these steps in order — watch the output:

| Step | What happens | Why |
|---|---|---|
| Minikube check | Starts Minikube only if it isn't already running | Avoids the slow cluster boot on repeat runs |
| `kubectl delete namespace spark-jobs` | Wipes all jobs, pods, and RBAC in that namespace | Clean slate without touching the cluster itself |
| `kubectl apply namespace + rbac` | Recreates `spark-jobs` namespace, `spark` ServiceAccount, Role + RoleBinding | Driver needs permission to create executor pods |
| Helm check | Installs the Spark Operator only if not already present | Operator image (~500 MB) is pulled once and reused |
| `eval $(minikube docker-env)` + `docker build` | Builds the app image **inside Minikube's Docker daemon** | Kubernetes can only find images that exist inside the cluster |

**Total time:** ~3 min on first run (Minikube start + Operator image pull), ~20 sec on subsequent runs.

Verify the environment is ready:

```bash
# Spark Operator pods should be Running
kubectl get pods -n spark-operator

# The spark ServiceAccount should exist
kubectl get serviceaccount spark -n spark-jobs

# Our Docker image should be listed
eval $(minikube docker-env) && docker images | grep spark-covid
```

---

## Part 3 — Submit the job and watch it run

Open **two terminals** side by side.

**Terminal 1 — watch pods:**
```bash
kubectl get pods -n spark-jobs -w
```

**Terminal 2 — submit the job:**
```bash
./scripts/run-analysis.sh
```

### What you'll see in Terminal 1

```
NAME                          READY   STATUS
covid-analysis-driver         0/1     Pending    ← operator creates driver first
covid-analysis-driver         1/1     Running
covid-analysis-...-exec-1     0/1     Pending    ← driver spawns executors
covid-analysis-...-exec-2     0/1     Pending
covid-analysis-...-exec-1     1/1     Running    ← all three pods running in parallel
covid-analysis-...-exec-2     1/1     Running
covid-analysis-...-exec-1     0/1     Completed  ← executors finish
covid-analysis-...-exec-2     0/1     Completed
covid-analysis-driver         0/1     Completed  ← driver finishes last
```

> This is distributed computing in Kubernetes. Three pods spawned, processed data in parallel, and cleaned up — managed by the Spark Operator.

### Why three pods, and not just one?

Because Spark is a distributed system — the work is intentionally split across separate processes so they run in parallel.

| Pod | Role | What it does in this job |
|---|---|---|
| `driver` | Coordinator | Downloads the CSV, builds the query plan, assigns tasks to executors, collects and prints results |
| `exec-1` | Worker | Processes its share of the 161k rows in parallel |
| `exec-2` | Worker | Processes its share of the 161k rows in parallel |

When `groupBy("Country").agg(max("Confirmed"))` runs, Spark first **partitions** the data — slices it into chunks, one per executor:

```
161,568 rows
    │
    ├── Partition 1 → exec-1 (~80,784 rows)  ─┐
    └── Partition 2 → exec-2 (~80,784 rows)  ─┴─ both run at the same time
                                                    │
                                              driver merges results
                                                    │
                                              final answer returned
```

> Spark distributes **partitions**, not individual rows. Row counts per executor are approximate — Spark decides partition sizes based on data and configuration, not by splitting rows evenly.

With 10 executors on 1 million rows, each handles ~100k rows simultaneously — the job finishes in roughly the same time as processing 100k rows on a single machine.

### What Spark handles automatically

You wrote `groupBy().agg().orderBy().limit()`. Spark handled everything else:

| Spark handled | What you'd do manually without it |
|---|---|
| Splitting data into partitions | Manually chunk the file and distribute it |
| Running tasks in parallel | Write multi-threading or multi-process code |
| Merging partial results from each executor | Manually collect and combine outputs |
| Requesting executor pods from K8s | Manually provision machines |
| Recovering if an executor dies | Detect the failure, restart manually |
| Query optimisation (Catalyst engine) | Hand-tune every aggregation |

You write *what* you want. Spark figures out *how* to run it across the cluster.

### What you'll see in Terminal 2 (log highlights)

| Log line | What it means |
|---|---|
| `Running Spark version 3.5.3` on `Linux aarch64` | Spark is running inside the container, on ARM64 Linux |
| `Going to request 2 executors from Kubernetes` | Driver is calling the K8s API to create executor pods |
| `No executor found for 10.244.0.x` | Executor pod started but hasn't registered yet — normal |
| `Registered executor ... with ID 1` | Executor connected to driver via Netty RPC |
| `SchedulerBackend is ready` | Minimum executors registered, job can now execute tasks |
| `Downloaded 161,568 records` | pandas fetch completed on the driver |
| `Distributed as Spark DataFrame` | Data partitioned and sent to executors |

---

## Part 4 — What is Kubernetes actually doing here?

> Run these **while the job is running** (start them right after `run-analysis.sh` in a separate terminal). They expose what K8s is doing behind the scenes.

### 4a. K8s scheduled and provisioned every pod

```bash
kubectl get events -n spark-jobs --sort-by='.lastTimestamp'
```

You'll see a machine-generated timeline of everything K8s did:

```
...  Scheduled   pod/covid-analysis-driver        Successfully assigned spark-jobs/covid-analysis-driver to minikube
...  Pulled      pod/covid-analysis-driver        Container image already present
...  Created     pod/covid-analysis-driver        Created container spark-kubernetes-driver
...  Started     pod/covid-analysis-driver        Started container spark-kubernetes-driver
...  Scheduled   pod/covid-19-analysis-...-exec-1 Successfully assigned ...
...  Started     pod/covid-19-analysis-...-exec-1 Started container spark-kubernetes-executor
```

Without K8s, you would have done all of this manually — picking a machine, SSH-ing in, starting the process, configuring networking. K8s did it automatically from a single `kubectl apply`.

### 4b. K8s enforces the resource limits you declared

```bash
kubectl describe pod covid-analysis-driver -n spark-jobs | grep -A6 "Limits:"
```

Expected:
```
Limits:
  cpu:     1200m
  memory:  512Mi
Requests:
  cpu:     1
  memory:  512Mi
```

These are the values from `covid-analysis.yaml`. The container physically cannot exceed them — K8s will throttle CPU and OOM-kill the pod if it tries. This is how multi-tenant clusters prevent one job from starving another. Note that Spark itself is unaware of these limits — Kubernetes enforces them at the container level, underneath Spark.

### 4c. K8s tracks the application state

```bash
kubectl get sparkapplication covid-analysis -n spark-jobs -o yaml | grep -A15 "applicationState:"
```

Expected (while running):
```yaml
applicationState:
  state: RUNNING
executorState:
  covid-19-analysis-...-exec-1: RUNNING
  covid-19-analysis-...-exec-2: RUNNING
```

The Spark Operator continuously reconciles this — if the actual state diverges from the declared state, it acts to correct it.

### 4d. Kill an executor — watch Spark recover

This is the most dramatic demo. While the job is running:

**Step 1** — get the executor pod name:
```bash
kubectl get pods -n spark-jobs -l spark-role=executor
```

**Step 2** — force-delete one executor:
```bash
kubectl delete pod <exec-pod-name> -n spark-jobs --grace-period=0 --force
```

**Step 3** — watch the driver logs immediately:
```bash
kubectl logs -f covid-analysis-driver -n spark-jobs
```

You'll see the driver detect the lost executor and request a replacement from K8s:
```
ExecutorPodsAllocator: Going to request 1 executors from Kubernetes ...
KubernetesClusterSchedulerBackend: Registered executor ... with ID 3
```

> The job continues. Spark told K8s "I need another executor", K8s created one. No human intervention. This is orchestration — and it's why Spark on K8s is used in production instead of manually managed clusters.

---

## Part 5 — Inspect the results (after job completes)

After the job completes, check the final state:

```bash
# Job status
kubectl get sparkapplication -n spark-jobs
# NAME             STATUS
# covid-analysis   COMPLETED

# Pod status — driver stays in Completed so logs are still accessible
kubectl get pods -n spark-jobs
# covid-analysis-driver   0/1   Completed   0   ...

# Re-read the results any time
kubectl logs covid-analysis-driver -n spark-jobs
```

**Q:** Why do the executor pods disappear but the driver pod stays?
> Executor pods are cleaned up immediately. The driver pod lingers in `Completed` state so logs remain accessible.

---

## Part 6 — Spark UI (run during the job, not after)

The Spark UI is only available while the driver pod is running. To catch it, start a fresh job then immediately open the UI.

```bash
# Terminal 1: resubmit
./scripts/cleanup.sh && ./scripts/run-analysis.sh

# Terminal 2: forward the UI port
./scripts/view-spark-ui.sh
# Open: http://localhost:4040
```

What to look at:
- **Jobs tab** — one job per Spark action (`show()`, `count()`) that was triggered; you'll see multiple jobs for the 4 analyses
- **Stages tab** — how each job was split into tasks distributed across executors
- **Executors tab** — CPU and memory usage per executor pod

> The UI disappears as soon as the driver pod completes.

---

## Part 7 — Scale up (change one number)

Edit `kubernetes/spark-jobs/covid-analysis.yaml` and change `instances: 2` to `instances: 4`:

```yaml
executor:
  instances: 4    # was 2
```

Resubmit and watch:

```bash
./scripts/cleanup.sh
kubectl apply -f kubernetes/spark-jobs/covid-analysis.yaml

# Watch in a second terminal
kubectl get pods -n spark-jobs -w
```

You'll now see 4 executor pods (`exec-1` through `exec-4`) instead of 2.

> Scaling in Spark on K8s is declarative — change a number, Kubernetes reconciles.

### Does 4 executors mean 2x faster?

Not for this dataset — and that's an important lesson.

Every Spark job has two parts:

```
Total time = sequential part + (parallel part ÷ number of executors)
                  │
                  └── data download, query planning, merging results
                      — this does NOT get faster with more executors
```

With 161k rows the computation itself finishes in milliseconds. The overhead of spawning 4 pods, distributing data to them, and merging results back becomes the dominant cost. You'd see no improvement, possibly slower.

More executors genuinely helps when the parallel work is large enough to dwarf the overhead:

| Scenario | More executors helps? | Why |
|---|---|---|
| 161k rows, simple aggregation | No | Data too small, overhead dominates |
| 100M+ rows, complex joins | Yes | Parallel work dominates |
| Wide transformations, many columns | Yes | More CPU work per row |
| Writing output to many partitions | Yes | I/O parallelised across executors |

**The honest takeaway for this demo:** the dataset is intentionally small enough to run in a classroom. The distributed architecture — driver, executors, partitioning, Catalyst optimiser — is identical to production. The scale where it pays off is gigabytes, not kilobytes. You're learning the pattern here, not benchmarking it.

Revert back to `instances: 2` when done.

---

## Part 8 — Clean up

```bash
# Remove the Spark job only (keeps cluster running for next time)
./scripts/cleanup.sh

# Or full reset
./scripts/reset.sh
```

---

## Summary

| Part | What you did | Concept |
|---|---|---|
| 1 | Read the code | Spark DataFrame API, SparkApplication CRD |
| 2 | Ran `reset.sh` | Minikube, Spark Operator, RBAC, Docker in Minikube |
| 3 | Watched pods spawn | Driver/executor lifecycle, distributed execution |
| 4 | K8s events, limits, killed a pod | Orchestration, resource enforcement, resilience |
| 5 | Inspected results | Completed pod state, log access |
| 6 | Opened Spark UI | DAG visualisation, stage/task breakdown |
| 7 | Changed `instances` | Declarative horizontal scaling |

---

## Troubleshooting

**Pods stuck in `Pending`:**
```bash
kubectl describe pod covid-analysis-driver -n spark-jobs
# Look at the Events section at the bottom
```

**Image not found (`ErrImageNeverPull`):**
```bash
# You built the image in the wrong Docker context — rebuild inside Minikube
eval $(minikube docker-env)
docker build -t spark-covid-analysis:latest -f docker/Dockerfile .
```

**Spark Operator not running:**
```bash
kubectl get pods -n spark-operator
kubectl logs -n spark-operator deployment/spark-operator-controller
```

**Start completely fresh:**
```bash
./scripts/reset.sh
```
