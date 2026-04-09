# 🧑‍💻 Temporal Workflows

Temporal is a workflow engine used for running background processes.

👉 Instead of writing complex async logic manually, Temporal handles:
- retries
- failures
- scheduling
- long-running tasks

---

# 🧩 Core Concepts

## 1. Workflow

A **workflow** is a process (or orchestration).

Example:
- process a file
- validate data
- store results

👉 Think of it as a “controller”

---

## 2. Activity

An **activity** is a single step of work.

Examples:
- call API
- insert into database
- transform data

👉 Think of it as a “function that does real work”

---

## 🧠 Mental Model

```text id="n1g64z"
Workflow → Activity → Database / API
````

* Workflow controls flow
* Activity executes logic

---

# ✍️ Basic Example

## Activity

```python id="h4eq3f"
from temporalio import activity

@activity.defn
async def greeting_activity(name: str) -> str:
    return f"Hello, {name}"
```

---

## Workflow

```python id="q3xqj6"
from temporalio import workflow
from datetime import timedelta

@workflow.defn
class ExampleWorkflow:
    @workflow.run
    async def run(self, name: str):
        return await workflow.execute_activity(
            greeting_activity,
            name,
            start_to_close_timeout=timedelta(seconds=10),
        )
```

---

# ⚙️ Worker

The worker runs workflows and activities.

```python id="u1v5m1"
from temporalio.worker import Worker

worker = Worker(
    client,
    task_queue="example-task-queue",
    workflows=[ExampleWorkflow],
    activities=[greeting_activity],
)
```

👉 If it’s not registered here → it will NOT run

---

# ▶️ Starting a Workflow

```python id="8ycvgi"
result = await client.execute_workflow(
    ExampleWorkflow.run,
    "John",
    id="workflow-1",
    task_queue="example-task-queue",
)
```

---

# 🔁 How Execution Works

```text id="1tlf3s"
1. You start workflow
2. Workflow runs
3. Workflow calls activity
4. Activity executes logic
5. Result is returned
```

---

# 🔄 Retries & Reliability

Temporal automatically handles:

* retries on failure
* persistence (state is saved)
* recovery after crash

👉 You don’t need to implement retry logic manually

---

# ⏱️ Timeouts

Activities must have timeouts:

```python id="w61u6q"
start_to_close_timeout=timedelta(seconds=10)
```

Without this → Temporal will fail the activity

---

# 🧪 Local Development

1. Start system:

```bash id="9r1bfu"
make start
```

2. Watch logs:

```bash id="1yqjdy"
make logs-app
```

3. Open UI:

```text id="j1k9ph"
http://localhost:8080
```

---

# 📊 Temporal UI

In the UI you can:

* see workflows
* inspect execution
* check errors
* retry workflows

---

# 🧠 Best Practices

✔ Keep workflows simple (orchestration only)
✔ Put heavy logic in activities
✔ Use small, reusable activities
✔ Always define timeouts

---

# ❌ Common Mistakes

❌ Putting DB logic inside workflow
❌ Forgetting to register activity in worker
❌ Missing timeouts
❌ Blocking code inside workflow

---

# 🧩 Typical Project Structure

```text id="bq8nmb"
src/
├── workflows/
│   └── example_workflow.py
├── activities/
│   └── user_activity.py
├── services/
│   └── user_service.py
```

---

# 📌 Summary

* Workflow = process
* Activity = step
* Worker = executor
* Temporal = orchestration engine

---

# ✅ TL;DR

```text id="qpsm6g"
Define Activity → Define Workflow → Register → Run
```

---
