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
demoNote: "Synthetic data only, with one-click demo sign-in. If the demo has been idle, the first request takes about 30 seconds while the server starts."
---

## The problem

AI in insurance decisions has to be auditable, and it must not make the final call. A model that approves a claim it shouldn't, with no trail of why, is a liability.

## What I built

- **A Spring Boot 3.5 / Java 21 modular monolith:** claims, policies, document ingestion (PDF to chunks to pgvector), decisions, human review and an append-only audit log. Flyway owns the schema.
- **Seven deterministic rules** (policy active, exclusions, coverage limit, waiting periods, pre-existing status, missing information, conflicting facts) with a strict order: REJECT beats REVIEW beats ALLOW.
- **The AI is consulted only when the rules allow.** A decision model (Parallel Decisions, via OpenRouter) picks one outcome and returns a probability for each. Java accepts an approval only at confidence 0.5 or above, turns an AI rejection with no rule behind it into a human review, and sends any AI or retrieval failure to a person.
- **RAG over policy wording** with NVIDIA NIM embeddings (query and passage) in pgvector with an HNSW index. Every decision stores a snapshot of the evidence it used: document, page, section and similarity.
- **Production basics:** JWT with three roles, rate limits on the AI endpoints, idempotency keys, Resilience4j timeouts, retries and a circuit breaker, Prometheus metrics, and a non-root Docker image with CI.
- **Deployed on AWS.** The Spring Boot app runs on Lambda as a container with the Lambda Web Adapter, behind a streaming Function URL, so the SSE events arrive live. CloudFront and S3 sit in front, CloudFormation defines it all, and GitHub Actions deploys every push with OIDC, so no AWS keys are stored. Postgres with pgvector runs on Neon.
- **A live event stream (SSE)** of every stage with server timings, the whole policy rulebook from Postgres, and the exact package the model received and what it answered. Synthetic data only.

## The hard parts

- **Keeping the model out of the final say.** The decision order is fixed in Java, so no prompt can talk its way into an approval the rules forbid.
- **Showing exactly what the AI saw.** The same object is serialised into the prompt and sent to the UI, so what the page shows is what the model got. No patient identity, ids or dates reach the model.
- **Failing safe.** Timeouts, bad JSON and empty retrieval all route to a person, not to a default answer.
- **A model retired mid-project.** The judge started on Inception's Mercury 2.5, and OpenRouter retired it in November 2026. Model ids were configuration from day one, so switching the judge to a decision model and the explanations to NVIDIA Nemotron changed no business logic.
- **A slow free model.** The free chat model that writes explanations often takes 30–50 seconds. Explanations now get a 40-second deadline, then fall back to a template that says it is one.

## Results

- **122 backend tests pass:** unit, contract tests against a mock model, Testcontainers with pgvector and LocalStack S3, and security. All run offline in CI, with no paid API.
- **A claim the rules decide skips the AI** and finishes in well under a second. The decision model answers in about 1–2 seconds.

The AI-assisted evaluation arm hasn't been run yet, so there's no accuracy number here. The rules-only run agrees with its own labels by design, so it isn't quoted as a result.

## What I'd do next

- Run the AI-assisted evaluation arm and publish the numbers.
- Move analysis to an async job model.
- Cut the cold start: the first request after the demo has been idle takes about 30 seconds while the JVM starts.
