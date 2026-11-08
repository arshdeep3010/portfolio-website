---
title: VibeAudit
pitch: Finds real bugs in AI-written apps with static analysis, an LLM pass and a sandbox.
order: 4
featured: true
status: code
tags: [GenAI, Backend]
stack: [FastAPI, SSE, Docker, bandit, semgrep]
metric: "<b>2 model calls</b> per snippet scan, down from about 12"
metricDate: "2026-11"
demo: vibe
links:
  code: ""
  demo: ""
  video: ""
---

## The problem

AI-written "vibe apps" ship with real bugs: hardcoded keys, SQL built from user input, endpoints with no limits. Their authors often can't read the code well enough to spot them.

## What I built

- **A scan pipeline:** ingest, map the project, triage the risky files, audit each file with an LLM, then rank the findings.
- **Classic tools first:** a secret scanner, bandit and semgrep, so the model checks real leads instead of guessing.
- **A verification pass** in which the model re-checks its own findings before they're shown.
- **A Docker sandbox** that builds and runs the app to catch build, boot and runtime errors.
- **Live progress** streamed to the browser over SSE.
- **A public mode** that accepts code snippets only, with size limits, per-IP and daily caps, a cache for repeated snippets, and results that expire after 24 hours.

## The hard parts

- **A failure that looked like success.** A failed model call once showed "grade A, spotless". Now a truncated or failed response is salvaged or reported as an error, never as a clean bill of health.
- **Cost.** A snippet scan used about 12 model calls. Folding the profile step into the audit and batching verification brought it to 2.

## Results

- **2 model calls** per snippet scan, down from about 12.
- **39.8 s** for the sample scan, down from 75–90 s.

Measured live in November 2026.

## What I'd do next

- A seeded-bug benchmark, so detection rate is measured, not described.
- A Dockerfile and CI for the service itself.
