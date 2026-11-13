---
title: LLM Gateway
pitch: One front door for every AI call. It keeps apps answering when a provider fails and keeps private details in.
order: 5
featured: true
status: live
tags: [Backend, GenAI]
stack: [Java 21, Spring Boot, Virtual threads, SSE, Terraform, GitHub Actions]
metric: "<b>20,000 / 20,000</b> answered with the first provider off · <b>72 tests</b>"
metricDate: "2026-11"
demo: gateway
links:
  code: "https://github.com/arshdeep3010/llm-gateway"
  demo: "https://d3ddocftym6j0y.cloudfront.net"
  video: ""
demoNote: "The hosted demo is a simulation: it runs a JavaScript copy of the gateway's steps in your browser, and says so on the page. The real gateway is a Java server. Every number here was measured on that server, which you can download and run from GitHub."
---

## The problem

An app that uses AI usually calls its model provider directly. That works for one app. With several, the same problems appear in each of them:

- **Providers fail.** FitCheck got HTTP 500s from NVIDIA, and a free model it relied on was withdrawn overnight.
- **Private details leave the company.** Users type names, phone numbers and ID numbers into prompts, and the prompt goes to an outside provider.
- **The same question is paid for many times.**
- **One app can use up the whole allowance**, by a bug or on purpose.
- **Nobody can answer** "what is our p95 latency?" or "what did this cost?"

## How the gateway solves it

Apps point their OpenAI SDK's base URL at the gateway and change nothing else. Every request then goes through the same steps:

| Step | What it does |
| --- | --- |
| Key check | Finds the app for a gateway key. Keys are held only as hashes. |
| Rate limit | A token bucket per app: a burst allowance plus a steady refill. |
| Budget | Monthly spend per app. Warns at 80%, blocks at 100%. |
| Injection check | Rules for the common attack phrasings. |
| Redaction | Emails, Indian phone numbers, PAN, Aadhaar and card numbers, and names after a cue, become placeholders such as `[PERSON_1]`. |
| Cache | The same question with the same settings returns the stored answer at no cost. |
| Provider call | Retry with backoff, then the next provider. A provider that keeps failing is skipped for 30 seconds. |
| Restore | Real values go back into the answer, also in a streamed one. |
| Log | Counts, timings and cost. Never the prompt or the answer. |

## What I built

- **An OpenAI-compatible API** in Java 21 and Spring Boot, with streaming. Each request runs on its own virtual thread, so the code is plain blocking code that still handles thousands of requests at once.
- **The reliability parts written by hand**, with no resilience library: a circuit breaker with closed, open and half-open states, retries with backoff and jitter, and a fallback chain.
- **Redaction that uses checksums.** A 12-digit number is treated as Aadhaar only if it passes the Verhoeff check, and a card number only if it passes Luhn, so order numbers are not hidden by mistake.
- **A cache keyed on the redacted prompt.** It never holds private values, and two people asking the same question with different names share one stored answer while each gets their own name back.
- **A playground and dashboard** that show every step a request went through, what left the gateway, and what came back.
- **A pipeline:** GitHub Actions runs 72 Java tests and 12 tests for the demo's browser copy on every push, then publishes the demo page to S3 and CloudFront. Terraform creates the AWS side, and GitHub signs in with a short-lived token, so no AWS keys are stored.

## The hard parts

- **Restoring placeholders in a stream.** A streamed answer arrives in pieces, and a placeholder can be cut in two: `[PERS` then `ON_1]`. The gateway holds back text after an unclosed bracket until the rest arrives, so half a placeholder never reaches the caller.
- **Falling back without lying.** Before the first piece of an answer is sent, a failed provider is retried and replaced. After that, the stream ends with an error: another provider would give a different answer, and the two cannot be joined.
- **A real model broke what the tests had passed.** I ran the gateway against NVIDIA Nemotron. The model spent its whole token allowance on reasoning, returned an empty answer, and the gateway cached it for ten minutes. That check found three bugs my simulated provider could never have shown. Now only complete answers are cached, the provider's finish reason is passed on, and request fields the gateway does not know are forwarded. Each fix has a test.

## Results

Measured on 12 November 2026, each run once, on one laptop, with the load generator on the same machine and simulated providers. All runs kept 200 requests in flight.

- **Outage: 20,000 of 20,000 answered** while the first provider was switched off for the middle 40% of the run. 14,000 answers came from the backup.
- **1,638 requests per second** with a provider that takes about 120 ms, at 121 ms p50.
- **98.8% cache hits** on 50 questions asked over and over.
- **29,001 requests per second** with zero provider delay, at 4.5 ms p50. This is the gateway's own ceiling.

Checked by hand against a real model, NVIDIA `nemotron-3-ultra-550b-a55b`: the model received `[PERSON_1]` and `[PAN_1]`, and the caller got "Hello Arjun Mehta, your PAN is ABCDE1234F." A repeat of the same request took 27 ms, against 3.1 seconds the first time.

## What I'd do next

- Move rate limits and the cache to Redis, and logs and budgets to Postgres. Today all state is in memory in one process.
- A labelled test set, to put precision and recall numbers on redaction and injection detection. Both use patterns today, so a name with no cue or a reworded attack gets through.
- Send FitCheck's traffic through it, so the dashboard shows real use.
