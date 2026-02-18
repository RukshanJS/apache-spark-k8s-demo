---
marp: true
paginate: true
backgroundColor: #ffffff
style: |
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800&family=JetBrains+Mono&display=swap');

  section {
    font-family: 'Inter', 'Segoe UI', Helvetica, Arial, sans-serif;
    font-size: 26px;
    padding: 48px 64px;
    color: #1a1a2e;
    background: #ffffff;
  }

  h1 {
    font-size: 1.9em;
    font-weight: 800;
    color: #E25A1C;
    border-bottom: 3px solid #E25A1C;
    padding-bottom: 10px;
    margin-bottom: 24px;
  }

  h2 {
    font-size: 1.35em;
    font-weight: 700;
    color: #1a1a2e;
    margin-top: 0;
  }

  h3 {
    font-size: 1em;
    color: #555;
    font-weight: 600;
  }

  code {
    font-family: 'JetBrains Mono', monospace;
    background: #f4f4f4;
    border-radius: 4px;
    padding: 2px 6px;
    font-size: 0.85em;
    color: #c0392b;
  }

  pre {
    background: #1e1e2e;
    color: #cdd6f4;
    border-radius: 10px;
    padding: 20px 24px;
    font-size: 0.72em;
    line-height: 1.6;
  }

  pre code {
    background: none;
    color: inherit;
    padding: 0;
  }

  .pill {
    display: inline-block;
    background: #E25A1C;
    color: white;
    padding: 3px 14px;
    border-radius: 20px;
    font-size: 0.75em;
    font-weight: 600;
    margin: 3px 2px;
  }

  .pill-blue {
    background: #2980b9;
  }

  .pill-green {
    background: #27ae60;
  }

  .pill-purple {
    background: #8e44ad;
  }

  .card {
    background: #fafafa;
    border: 1.5px solid #eee;
    border-radius: 12px;
    padding: 18px 22px;
    margin: 10px 0;
  }

  .card-orange {
    border-left: 5px solid #E25A1C;
    background: #fff8f4;
  }

  .card-blue {
    border-left: 5px solid #2980b9;
    background: #f4f9ff;
  }

  .card-green {
    border-left: 5px solid #27ae60;
    background: #f4fff8;
  }

  .meme-box {
    background: #1a1a2e;
    color: white;
    border-radius: 14px;
    padding: 28px 36px;
    text-align: center;
    font-size: 1.1em;
    font-weight: 700;
    letter-spacing: 0.5px;
    margin: 16px auto;
    max-width: 680px;
  }

  .meme-top {
    font-size: 1.05em;
    text-transform: uppercase;
    letter-spacing: 2px;
    color: #aaa;
    margin-bottom: 12px;
  }

  .meme-bottom {
    font-size: 1.2em;
    text-transform: uppercase;
    letter-spacing: 2px;
    color: #E25A1C;
    margin-top: 12px;
  }

  .meme-emoji {
    font-size: 3em;
    margin: 8px 0;
  }

  .two-col {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 28px;
  }

  .three-col {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 18px;
  }

  .step {
    background: #fafafa;
    border: 1.5px solid #eee;
    border-radius: 12px;
    padding: 16px 18px;
    text-align: center;
  }

  .step-num {
    font-size: 2em;
    font-weight: 800;
    color: #E25A1C;
    line-height: 1;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    font-size: 0.88em;
  }

  th {
    background: #E25A1C;
    color: white;
    padding: 10px 14px;
    text-align: left;
    font-weight: 700;
  }

  td {
    padding: 9px 14px;
    border-bottom: 1px solid #f0f0f0;
  }

  tr:nth-child(even) td {
    background: #fafafa;
  }

  section.title-slide {
    display: flex;
    flex-direction: column;
    justify-content: center;
    padding: 60px 80px;
  }

  section.section-break {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    text-align: center;
    background: #1a1a2e;
    color: white;
  }

  section.section-break h1 {
    color: #E25A1C;
    border-color: #E25A1C;
    font-size: 2.2em;
  }

  section.section-break p {
    color: #ccc;
    font-size: 1em;
  }

  .tag {
    display: inline-block;
    background: #fff3e0;
    border: 1.5px solid #E25A1C;
    color: #E25A1C;
    padding: 2px 12px;
    border-radius: 20px;
    font-size: 0.75em;
    font-weight: 700;
    margin-bottom: 10px;
  }

  footer {
    font-size: 0.6em;
    color: #aaa;
  }
---

<!-- _class: title-slide -->
<!-- _paginate: false -->

<div class="tag">GUEST SESSION · 18 FEB 2026</div>

# Apache Spark on Kubernetes

### From your laptop to a distributed computing cluster — in 2 hours

<br>

**Rukshan J. Senanayaka**
Faculty of Information Technology · University of Moratuwa
Big Data Module · 1:15 pm – 3:15 pm

---

# What we're covering today

<div class="two-col">
<div>

**Concepts** 💡
- Why containers exist (Docker)
- Why we need an orchestrator (Kubernetes)
- Why distributed computing (Apache Spark)
- Why Spark runs on Kubernetes

</div>
<div>

**Hands-on** 🛠️
- Start a Kubernetes cluster locally
- Deploy the Spark Operator
- Submit a real Spark job
- Watch distributed execution live
- Kill a pod. Watch it recover.
- Scale with one number change

</div>
</div>

<br>

<div class="card card-orange">
🎯 <strong>Goal:</strong> By the end, you'll understand what happens from <code>kubectl apply</code> to a result printed on screen — at every layer.
</div>

---

<!-- _class: section-break -->

# 🐳 Chapter 1
## The Container Problem

---

# The world before containers

Every developer has said this at least once:

<br>

<div class="meme-box">
  <div class="meme-top">Code works perfectly on dev laptop</div>
  <div class="meme-emoji">💻 → 🔥</div>
  <div class="meme-bottom">Crashes immediately on the server</div>
</div>

<br>

**Why?** Different OS versions, Python versions, library versions, environment variables, file paths, system dependencies...

---

# What Docker solves

<div class="two-col">
<div>

## The problem
- "Works on my machine"
- Different environments = different behaviour
- Painful manual setup on every server
- "Did you install the right Python version?"

</div>
<div>

## The solution: containers
A **container** packages:
- Your application code
- Runtime (Python, JVM, etc.)
- All dependencies
- Configuration

Runs **identically** everywhere.

</div>
</div>

<br>

<div class="card card-orange">
🐳 <strong>Think of it like this:</strong> A shipping container — you pack everything inside. The ship (server) doesn't need to know what's in it. It just moves containers.
</div>

---

# Docker vs Virtual Machines

<div class="two-col">
<div>

## Virtual Machine
```
┌───────────────────┐
│    Application    │
│    Guest OS       │  ← full OS copy
│    Hypervisor     │
│    Host OS        │
│    Hardware       │
└───────────────────┘
```
Heavy. Minutes to start. GBs each.

</div>
<div>

## Container
```
┌───────────────────┐
│  App A  │  App B  │
│  Deps A │  Deps B │
│    Container RT   │  ← shared kernel
│       Host OS     │
│       Hardware    │
└───────────────────┘
```
Lightweight. Seconds to start. MBs each.

</div>
</div>

<br>

<div class="card card-blue">
Containers share the host OS kernel — they're isolated processes, not full machines. That's why they're so fast.
</div>

---

# A Docker image is a recipe

Our `Dockerfile` builds the image for this demo:

```dockerfile
FROM apache/spark:3.5.3-python3    # Start from official Spark image

RUN pip install pandas             # Add our dependency

COPY src/covid_analysis.py \       # Copy our script in
     /opt/spark/work-dir/
```

**Build once → run anywhere:**

<div class="three-col">
<div class="step">
<div class="step-num">1</div>
<strong>Write</strong> a Dockerfile
</div>
<div class="step">
<div class="step-num">2</div>
<strong>Build</strong> an image
</div>
<div class="step">
<div class="step-num">3</div>
<strong>Run</strong> a container anywhere
</div>
</div>

---

<!-- _class: section-break -->

# ☸️ Chapter 2
## Enter Kubernetes

---

# Docker solved packaging. New problem:

<br>

<div class="meme-box">
  <div class="meme-top">"Just run it in a container!"</div>
  <div class="meme-emoji">📦 📦 📦 📦 📦 📦 📦 📦 📦 📦 📦 📦</div>
  <div class="meme-bottom">Cool. Now manage 200 of them across 50 servers.</div>
</div>

<br>

Questions that appear immediately:
- Which server has enough resources to run this?
- What if a container crashes?
- How do containers talk to each other?
- How do I deploy a new version without downtime?

---

# What Kubernetes does

**Kubernetes (K8s)** is a container orchestrator — it manages containers at scale so you don't have to.

<br>

| You declare... | Kubernetes handles... |
|---|---|
| "I want 2 instances of this app" | Finding servers with free resources |
| "This pod needs 512MB RAM" | Enforcing that limit at the OS level |
| "Restart if it crashes" | Detecting failure and restarting |
| "Deploy v2 without downtime" | Rolling update, traffic switching |
| "These pods need to talk" | Internal networking and DNS |

<br>

<div class="card card-blue">
☸️ The key insight: you describe <strong>what you want</strong>. Kubernetes figures out <strong>how to make it happen</strong> and keeps it that way continuously.
</div>

---

# Kubernetes core concepts

<div class="three-col">
<div class="card">
<strong>Pod</strong><br><br>
The smallest unit. One or more containers that run together. Gets its own IP address.
</div>
<div class="card">
<strong>Namespace</strong><br><br>
A logical partition. Like a folder for your resources. Isolates teams and workloads.
</div>
<div class="card">
<strong>Node</strong><br><br>
A machine (physical or VM) in the cluster. Pods run on nodes.
</div>
</div>

<div class="three-col" style="margin-top:16px">
<div class="card">
<strong>Deployment</strong><br><br>
Declares: "run N copies of this pod." Handles rolling updates.
</div>
<div class="card">
<strong>Service</strong><br><br>
A stable network address for a set of pods. Load balances between them.
</div>
<div class="card">
<strong>CRD</strong><br><br>
Custom Resource Definition. Extend K8s with your own resource types — like <code>SparkApplication</code>.
</div>
</div>

---

# RBAC — why it matters

In Kubernetes, **pods have no permissions by default**.

Our Spark driver pod needs to create executor pods at runtime — that's a Kubernetes API call that will be rejected unless we explicitly allow it.

<br>

```
ServiceAccount "spark"  →  Role "spark-role"  →  RoleBinding
      │                          │
      │                    Allowed to:
      │                    • create pods
      │                    • delete pods
      │                    • manage services
      └──────────────────────────┘
         driver pod runs AS this identity
```

<br>

<div class="card card-orange">
Without RBAC: <code>403 Forbidden</code> the moment the driver tries to spawn executors.
</div>

---

<!-- _class: section-break -->

# ⚡ Chapter 3
## Apache Spark

---

# The big data problem

<br>

<div class="meme-box">
  <div class="meme-top">Your dataset: 500 GB CSV file</div>
  <div class="meme-emoji">💾 → 💻</div>
  <div class="meme-bottom">Your laptop's RAM: 16 GB</div>
</div>

<br>

Even if the data fits — processing it sequentially on one machine is slow. A single-threaded Python script on 1 billion rows could take hours.

**The answer:** split the data, process it on many machines in parallel, combine results.

---

# What Apache Spark is

**Apache Spark** is a distributed data processing engine. You write what you want — Spark figures out how to run it across a cluster.

<br>

<div class="two-col">
<div>

## What you write
```python
df.groupBy("Country") \
  .agg(max("Confirmed")) \
  .orderBy(desc("Total")) \
  .limit(10)
```
Looks like pandas. Familiar API.

</div>
<div>

## What Spark does
- Splits data into partitions
- Sends partitions to worker nodes
- Runs aggregation in parallel
- Merges partial results
- Returns the final answer

</div>
</div>

---

# Driver and Executors

Every Spark job has two roles:

<br>

<div class="two-col">
<div class="card card-orange">

## 🎯 Driver
**The coordinator**

- Parses your code
- Builds an execution plan
- Assigns tasks to executors
- Collects final results

One per job. Your Python script runs here.

</div>
<div class="card card-blue">

## ⚙️ Executors
**The workers**

- Receive tasks from the driver
- Load their partition of data
- Run the computation
- Return results to driver

As many as you configure. Run in parallel.

</div>
</div>

---

# How data gets distributed

<br>

```
161,568 rows (COVID-19 dataset)
         │
         ▼
   Spark partitions it
         │
         ├── Partition 1 → exec-1 (~80k rows)  ┐
         └── Partition 2 → exec-2 (~80k rows)  ┘ run simultaneously
                                                │
                                         driver merges
                                                │
                                         final answer
```

<br>

<div class="card card-green">
Spark distributes <strong>partitions</strong>, not individual rows. With 10 executors and 1M rows, each handles ~100k rows at the same time — the job finishes in roughly the time it takes to process 100k rows.
</div>

---

# What Spark handles automatically

You wrote 4 lines of Python. Spark handled:

| Spark handled | What you'd do manually |
|---|---|
| Splitting data into partitions | Manually chunk the file |
| Sending partitions to workers | SSH into each machine, load data |
| Running tasks in parallel | Write multi-threading code |
| Merging partial results | Manually collect and combine |
| Optimising the query (Catalyst) | Hand-tune every aggregation |
| Recovering if an executor dies | Detect failure, restart manually |

<br>

<div class="card card-orange">
⚡ You write <em>what</em> you want. Spark figures out <em>how</em> to run it across the cluster.
</div>

---

<!-- _class: section-break -->

# 🚀 Chapter 4
## Spark on Kubernetes

---

# Why run Spark on Kubernetes?

Traditionally Spark ran on dedicated clusters (YARN, Mesos, standalone). Kubernetes brings new advantages:

<br>

<div class="two-col">
<div>

<div class="card card-orange">
<strong>🔄 Dynamic scaling</strong><br>
Request exactly the executors you need. Return resources when done.
</div>

<div class="card card-blue" style="margin-top:14px">
<strong>🏢 Multi-tenancy</strong><br>
Multiple teams, multiple Spark jobs, isolated in separate namespaces.
</div>

</div>
<div>

<div class="card card-green">
<strong>📋 Declarative</strong><br>
Define a <code>SparkApplication</code> YAML. Kubernetes reconciles the rest.
</div>

<div class="card" style="margin-top:14px; border-left: 5px solid #8e44ad; background: #fdf4ff">
<strong>☁️ Cloud-native</strong><br>
Reuse the same K8s tooling — monitoring, logging, autoscaling — for Spark.
</div>

</div>
</div>

---

# The Spark Operator

Managing driver and executor pods manually would be complex. The **Spark Operator** (by Kubeflow) adds a new resource type to Kubernetes: `SparkApplication`.

<br>

```
You run:   kubectl apply -f covid-analysis.yaml

Spark Operator sees it → creates driver pod
Driver starts          → calls K8s API to create executor pods
Executors register     → job runs
Job completes          → pods cleaned up automatically
```

<br>

<div class="card card-blue">
The Operator follows the <strong>Kubernetes Operator pattern</strong>: a controller that watches for custom resources and acts to reconcile desired state with actual state — continuously.
</div>

---

# Our demo architecture

```
Your Mac (host)
└── Docker Desktop
    └── Minikube  (single-node Kubernetes cluster)
        │
        ├── Namespace: spark-operator
        │   └── spark-operator-controller   ← watches for SparkApplication CRDs
        │
        └── Namespace: spark-jobs
            ├── covid-analysis-driver       ← 1 core, 512MB — your Python script
            ├── covid-analysis-exec-1       ← 1 core, 512MB — processes half the data
            └── covid-analysis-exec-2       ← 1 core, 512MB — processes half the data
```

<br>

<span class="pill">Minikube</span> local K8s cluster inside Docker
<span class="pill pill-blue">Spark Operator</span> manages SparkApplication CRDs
<span class="pill pill-green">spark-jobs namespace</span> all Spark pods run here

---

# The SparkApplication CRD

One YAML file declares the entire job:

```yaml
apiVersion: sparkoperator.k8s.io/v1beta2
kind: SparkApplication          # ← our custom resource type
metadata:
  name: covid-analysis
  namespace: spark-jobs
spec:
  image: spark-covid-analysis:latest
  mainApplicationFile: local:///opt/spark/work-dir/covid_analysis.py

  driver:
    cores: 1
    memory: "512m"
    serviceAccount: spark       # ← uses the RBAC we set up

  executor:
    instances: 2                # ← change this number to scale
    cores: 1
    memory: "512m"
```

---

<!-- _class: section-break -->

# 🛠️ Live Demo
## Let's build this

---

# What we'll do — step by step

<div class="two-col">
<div>

<div class="step" style="margin-bottom:12px">
<div class="step-num">1</div>
Read the code before running anything
</div>

<div class="step" style="margin-bottom:12px">
<div class="step-num">2</div>
Run <code>reset.sh</code> — watch the cluster come up
</div>

<div class="step" style="margin-bottom:12px">
<div class="step-num">3</div>
Submit the job — watch pods spawn live
</div>

</div>
<div>

<div class="step" style="margin-bottom:12px">
<div class="step-num">4</div>
Inspect K8s events, resource limits, state tracking
</div>

<div class="step" style="margin-bottom:12px">
<div class="step-num">5</div>
<strong>Kill an executor</strong> — watch Spark recover
</div>

<div class="step" style="margin-bottom:12px">
<div class="step-num">6</div>
Scale executors — and learn why more ≠ faster
</div>

</div>
</div>

<br>

<div class="card card-orange">
📖 Follow along: <code>docs/HANDS-ON-LAB.md</code>
</div>

---

# Watch the pod lifecycle

When you submit the job, run this in a second terminal:

```bash
kubectl get pods -n spark-jobs -w
```

You'll watch this unfold in real time:

```
NAME                          READY   STATUS
covid-analysis-driver         0/1     Pending            ← operator creates driver
covid-analysis-driver         1/1     Running
covid-analysis-...-exec-1     0/1     Pending            ← driver spawns executors
covid-analysis-...-exec-2     0/1     Pending
covid-analysis-...-exec-1     1/1     Running            ← all 3 running in parallel
covid-analysis-...-exec-2     1/1     Running
covid-analysis-...-exec-1     0/1     Completed          ← job finishes
covid-analysis-driver         0/1     Completed
```

<div class="card card-green" style="margin-top:16px">
Each line is a <strong>state change event</strong> — Kubernetes is telling you what it's doing in real time.
</div>

---

# The executor kill demo

While the job is running:

```bash
# Step 1: get an executor pod name
kubectl get pods -n spark-jobs -l spark-role=executor

# Step 2: force delete it
kubectl delete pod <exec-pod-name> -n spark-jobs --grace-period=0 --force

# Step 3: watch the driver log
kubectl logs -f covid-analysis-driver -n spark-jobs
```

<br>

You'll see:
```
ExecutorPodsAllocator: Going to request 1 executors from Kubernetes ...
KubernetesClusterSchedulerBackend: Registered executor ... with ID 3
```

<div class="card card-orange" style="margin-top:16px">
🔥 No human intervention. Spark asked K8s for a replacement. K8s created one. <strong>The job continues.</strong> This is why Spark on K8s is used in production.
</div>

---

# The scaling trap

After scaling to 4 executors — does the job run 2× faster?

<br>

<div class="meme-box">
  <div class="meme-top">Me: changes instances from 2 to 4</div>
  <div class="meme-emoji">⏱️ → ⏱️</div>
  <div class="meme-bottom">The job: takes exactly the same time</div>
</div>

<br>

**Why?** Amdahl's Law:

```
Total time = sequential overhead + (parallel work ÷ executors)
                    │
                    └── data download, query planning, merging results
                        — this does NOT get faster with more executors
```

With 161k rows, the data is too small. Overhead dominates.

---

# When scaling actually helps

| Scenario | More executors helps? | Why |
|---|---|---|
| 161k rows, simple aggregation | ❌ No | Data too small, overhead dominates |
| 100M+ rows, complex joins | ✅ Yes | Parallel work dominates |
| Wide transforms, many columns | ✅ Yes | More CPU work per row |
| Writing output to many files | ✅ Yes | I/O parallelised |
| ML model training on partitions | ✅ Yes | Each partition trains independently |

<br>

<div class="card card-orange">
The dataset in this demo is intentionally small. The <strong>architecture</strong> is identical to production. The scale where it pays off is gigabytes, not kilobytes. You're learning the pattern.
</div>

---

<!-- _class: section-break -->

# 🎓 Key Takeaways

---

# What you learned today

<div class="two-col">
<div>

**Docker** 🐳
- Containers package app + dependencies
- Run identically everywhere
- Lightweight vs VMs

**Kubernetes** ☸️
- Orchestrates containers at scale
- Declarative: you say what, K8s says how
- RBAC controls what pods can do
- CRDs extend K8s with custom resource types

</div>
<div>

**Apache Spark** ⚡
- Driver coordinates, executors compute
- Data is partitioned across executors
- Aggregations run in parallel
- Catalyst engine optimises queries

**Spark on K8s** 🚀
- Spark Operator manages the lifecycle
- Dynamic executor provisioning
- Resilient: lost executor → new one requested
- Declarative scaling via `instances:`

</div>
</div>

---

# The mental model

<br>

```
You write Python (what you want)
    │
    ▼
Spark translates it to a distributed execution plan (Catalyst)
    │
    ▼
Spark Operator creates the pods in Kubernetes
    │
    ▼
Kubernetes schedules pods, enforces resource limits, handles failures
    │
    ▼
Docker containers run your code, isolated and reproducible
    │
    ▼
Result printed to your terminal
```

<br>

Every layer you met today is a real production tool used at scale — Spotify, Uber, LinkedIn, Netflix.

---

# Where to go next

<div class="two-col">
<div>

**Spark deeper**
- Spark SQL (query data like a database)
- Spark Streaming (real-time data)
- MLlib (distributed machine learning)
- Delta Lake (ACID transactions on data lakes)

**Kubernetes deeper**
- Helm (package manager)
- Ingress (external traffic routing)
- Persistent Volumes (stateful apps)
- Horizontal Pod Autoscaler

</div>
<div>

**This demo**
- GitHub: `RukshanJS/apache-spark-k8s-demo`
- Follow `docs/HANDS-ON-LAB.md`
- Try changing the dataset
- Try adding a new analysis
- Try raising `executor.instances`

<br>

<div class="card card-orange">
🔗 All the code you ran today is open and documented. Clone it, break it, learn from it.
</div>

</div>
</div>

---

<!-- _class: section-break -->
<!-- _paginate: false -->

# Thank you

<br>

**Rukshan J. Senanayaka**

<br>

Repository: `github.com/RukshanJS/apache-spark-k8s-demo`

Lab guide: `docs/HANDS-ON-LAB.md`

<br>

*Questions?*
