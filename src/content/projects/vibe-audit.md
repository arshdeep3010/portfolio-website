---
title: VibeAudit
pitch: Finds the bugs that AI-written code ships with, before that code reaches real users.
order: 4
featured: true
status: live
tags: [GenAI, Backend]
stack: [FastAPI, LLM, SSE, Docker, bandit, semgrep]
metric: "<b>Every planted bug</b> found in 39.8 s · <b>2 model calls</b>"
metricDate: "2026-11"
demo: vibe
links:
  code: "https://github.com/arshdeep3010/vibe-audit"
  demo: "https://d2vy8g526grxgy.cloudfront.net"
  video: ""
---

## The problem

More and more apps are "vibe-coded": someone describes what they want, and an AI writes it. That code often runs and looks fine, which is exactly why it's risky.

- **It works on the happy path but breaks under attack or edge cases.** Typical mistakes include SQL built from user input, `jwt.decode` used where it should be `jwt.verify` (so anyone can fake a login), live API keys pasted into the source, and a checkout whose async loop means it always charges $0.
- **The people building these apps often can't spot those bugs.** Vibe coding lets non-experts ship, but they can't review code they didn't write and don't fully understand.
- **Existing tools miss half of it.** Scanners such as semgrep and bandit catch known patterns, but not logic bugs like the $0 checkout. A human review catches both, but it's slow and costs money.
- **Asking ChatGPT to "check my code" isn't reliable.** It invents problems, misses real ones, gives no consistent severity, and doesn't say whether it actually checked everything.

## How VibeAudit solves it

| Pain | What VibeAudit does |
| --- | --- |
| Leaked keys | A pattern scan catches them for free, without relying on the model |
| Logic and security bugs that rules miss | An LLM audit asks for exact lines, a CWE and a concrete fix for each bug |
| AI false alarms | A second, sceptical pass tries to disprove each serious finding and drops the weak ones |
| "Is this safe to ship?" | One ranked list and an A–F grade, so the worst thing gets fixed first |
| Silent failures | If the model fails, the report says so instead of showing a fake grade A |
| Cost | 2 model calls per snippet, and re-running the same snippet is free |

## What I built

- **A scan pipeline:** ingest, map the project, triage the risky files, audit each one with an LLM, verify, then rank and grade the findings.
- **Classic tools first:** a secret scanner, bandit and semgrep, so the model checks real leads instead of guessing.
- **A sceptical verification pass** that tries to disprove each serious finding before it's shown.
- **A Docker sandbox** that builds and runs the app to catch build, boot and runtime errors.
- **Live progress** streamed to the browser over SSE.
- **A public mode** that accepts snippets only, masks secrets in the report, uses report IDs that can't be guessed, sends security headers, and enforces size limits, per-IP and daily caps. Results expire after 24 hours.

## The hard parts

- **A failure that looked like success.** A failed model call once showed "grade A, spotless". Now a cut-off reply is salvaged, a failed one is retried, and if it still fails the report says so. It never shows a clean grade it didn't earn.
- **Cost.** A snippet scan used about 12 model calls. Folding the profile step into the audit and batching verification brought it to 2. Caching makes a repeat scan free, and rate limits cap what the public mode can spend.
- **False positives.** A model asked to find bugs will find some whether they exist or not. The second pass argues against each serious finding, and only the ones that survive are reported.

## Results

On a sample of AI-written code with planted bugs (SQL injection, a forgeable JWT login, hardcoded live keys, and the $0 async checkout):

- **Found every planted bug**, each with its line number and a fix.
- **39.8 s** for the whole scan, down from 75–90 s.
- **2 model calls** per snippet, down from about 12.
- **The sceptical pass dropped 1 weak finding** that would otherwise have been a false alarm.

Measured live in November 2026.

## What I'd do next

- A larger seeded-bug benchmark, so the detection rate is a number across many samples, not one.
- A Dockerfile and CI for the service itself.
