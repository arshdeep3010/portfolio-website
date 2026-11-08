---
title: AgentOps
pitch: Agent workflows that survive crashes, wait for people, and ship code through SDLC gates.
order: 1
featured: true
status: code
tags: [Agents, Backend]
stack: [Python, FastAPI, Postgres, Docker, LLM]
metric: "<b>0 lost runs</b> in 500 · 435 random kills"
metricDate: "2026-11"
demo: chaos
links:
  code: ""
  demo: ""
  video: ""
---

## The problem

AI agents that run many steps die halfway through. When they're retried, they repeat side effects like charging a card twice. And when they write code, they skip the engineering discipline a team would insist on: agreed requirements, tests first, review. When tests fail, they may even edit the tests until they pass.

## What I built

- **A workflow engine on Postgres alone.** An event log that is the source of truth, a `SKIP LOCKED` job queue, worker leases with heartbeats and fencing tokens, idempotent tool calls, approvals that hold no worker while they wait, budgets, cancel, and replay from any step. Live updates reach the browser over SSE, woken by `LISTEN/NOTIFY`.
- **A 12-step SDLC pipeline on top.** Requirements, then design (each approved by a person), then tests written first, then build, looping through 9 quality gates, then an AI review, then a pull request with a traceability matrix, then a merge a person approves.
- **Rules that stop the model cheating.** Every acceptance criterion needs a test that fails before any code exists, and a test with no assert is rejected before it runs. Then the tests are hashed and locked: any change to them fails the run. Changing files outside the approved design fails the scope gate.
- **A locked-down Docker sandbox** for AI-written code: no network, read-only, 512 MB, 1 CPU, non-root, hard timeout. The gates are pytest, test lock, scope lock, protected files, secrets, syntax, changed-line coverage of at least 80%, ruff, mypy and bandit.
- **A live UI** for one real task: adding discount coupons to ShopLite, a small FastAPI shop. You see the shop before, watch each step tick, read every document, approve, and open the new shop after the merge.

## The hard parts

- **Late results from a dead worker.** A worker can be killed, lose its lease, and still finish its step later. Fencing tokens make the database reject that stale write, so only the worker that took over counts.
- **Loops without cycles.** "Build until the gates pass" is a loop, but the workflow is a DAG. A failed gate rewinds an earlier step with the evidence as feedback, inside a loop budget, so a stuck build stops and asks a person instead of running forever.
- **Tests that checked nothing.** On the first live run the model wrote 5 tests whose body was only `pass`, and the red check rejected them 4 rounds in a row. Now requirements must use data that exists in the repo, and a test with no assert is refused by name before it runs.
- **A reviewer that flip-flopped.** The AI reviewer invented a crash the tests disproved, and later repeated the same comments word for word. It now sees its own earlier rounds, a blocking comment needs a concrete failing case, and repeated comments go to the person at the merge approval.

## Results

- **Chaos test (4 Nov 2026):** 500 runs while 3 worker processes were hard-killed at random, 435 times. 0 runs lost, 0 duplicate side effects (the idempotency key deduped all 59 repeated requests), median takeover 1.9 s.
- **Live ShopLite run (7 Nov 2026):** a coupon feature from requirements to merged code in 5.5 minutes on a free NVIDIA model. 9 tests failed first and were locked, build 1 failed a locked test, build 3 passed all 9 checks, and the merged shop charged the right total.
- **Earlier live run (4 Nov 2026):** a refunds task to a pull request through all 9 gates in 4.0 minutes, with 100% of changed lines covered.

These are single debugging runs, not a benchmark. The chaos test used a fake model, so it measures durability, not throughput.

## What I'd do next

- Benchmark the SDLC pipeline against a one-shot prompt on hidden tests, to show what the gates are worth.
- Open real GitHub pull requests instead of a local PR file.
