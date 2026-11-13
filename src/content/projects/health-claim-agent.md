---
title: Health Claim Agent
pitch: AI-assisted claim decisions where the Java backend, not the model, makes the final call.
order: 3
featured: true
status: live
tags: [GenAI, Backend]
stack: [Java 21, Spring Boot, pgvector, RAG, SSE]
metric: "<b>122 backend tests</b> · AI called only after 7 rules pass"
metricDate: "2026-11"
demo: health
links:
  code: "https://github.com/arshdeep3010/health-claim-decision-agent"
  demo: "https://d97tm0469lmul.cloudfront.net/"
  video: ""
---

## The problem

AI in insurance decisions has to be auditable, and it must not make the final call. A model that approves a claim it shouldn't, with no trail of why, is a liability.

## What I built

- **A Spring Boot 3.5 / Java 21 modular monolith:** claims, policies, document ingestion (PDF to chunks to pgvector), decisions, human review and an append-only audit log. Flyway owns the schema.
- **Seven deterministic rules** (policy active, exclusions, coverage limit, waiting periods, pre-existing status, missing information, conflicting facts) with a strict order: REJECT beats REVIEW beats ALLOW.
- **The AI is consulted only when the rules allow.** Mercury (via OpenRouter) answers in a strict JSON schema. Java accepts an approval only at confidence 0.5 or above, turns an AI rejection with no rule behind it into a human review, and sends any AI or retrieval failure to a person.
- **RAG over policy wording** with NVIDIA NIM embeddings (query and passage) in pgvector with an HNSW index. Every decision stores a snapshot of the evidence it used: document, page, section and similarity.
- **Production basics:** JWT with three roles, rate limits on the AI endpoints, idempotency keys, Resilience4j timeouts, retries and a circuit breaker, Prometheus metrics, and a non-root Docker image with CI.
- **A live event stream (SSE)** of every stage with server timings, the whole policy rulebook from Postgres, and the exact package the model received and what it answered. Synthetic data only.

## The hard parts

- **Keeping the model out of the final say.** The decision order is fixed in Java, so no prompt can talk its way into an approval the rules forbid.
- **Showing exactly what the AI saw.** The same object is serialised into the prompt and sent to the UI, so what the page shows is what the model got. No patient identity, ids or dates reach the model.
- **Failing safe.** Timeouts, bad JSON and empty retrieval all route to a person, not to a default answer.

## Results

- **122 backend tests pass:** unit, contract tests against a mock model, Testcontainers with pgvector and LocalStack S3, and security. All run offline in CI, with no paid API.
- **A claim the rules decide skips the AI** and finishes in well under a second. One AI call takes about 3–5 seconds.

The AI-assisted evaluation arm hasn't been run yet, so there's no accuracy number here. The rules-only run agrees with its own labels by design, so it isn't quoted as a result.

## What I'd do next

- Run the AI-assisted evaluation arm and publish the numbers.
- Move analysis to an async job model and deploy a public demo with synthetic data.
