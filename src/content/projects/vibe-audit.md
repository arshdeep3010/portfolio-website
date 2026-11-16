---
title: VibeAudit
pitch: Finds the bugs that AI-written code ships with, before that code reaches real users.
order: 4
featured: true
status: live
tags: [GenAI, Backend]
stack: [FastAPI, LLM, Semgrep, bandit, Docker, AWS Lambda, Terraform]
metric: "<b>Every planted bug</b> found · <b>16 Semgrep hits</b> judged by the model · <b>2 model calls</b>"
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
- **Each kind of tool misses half of it.** Rule-based scanners such as Semgrep and bandit catch known patterns but over-report, and they miss logic bugs like the $0 checkout. A human review catches both, but it's slow and costs money.
- **Asking ChatGPT to "check my code" isn't reliable.** It invents problems, misses real ones, gives no consistent severity, and doesn't say whether it actually checked everything.

## How VibeAudit solves it

| Pain | What VibeAudit does |
| --- | --- |
| Leaked keys | A pattern scan catches them for free, without relying on the model |
| Known bug patterns | Semgrep runs 42 rules I wrote for this project, plus bandit for Python |
| Scanner noise | The model judges every Semgrep and bandit hit: it confirms or dismisses it with a reason, and writes the impact and fix for this code |
| Logic bugs that rules miss | An LLM audit asks for exact lines, a CWE and a concrete fix for each bug |
| AI false alarms | A second, sceptical pass tries to disprove each serious finding and drops the weak ones |
| "Is this safe to ship?" | One ranked list and an A–F grade, so the worst thing gets fixed first |
| Silent failures | If the model fails, the report says so instead of showing a fake grade A |
| Cost | Still 2 model calls per snippet, and re-running the same snippet is free |

## What I built

- **A scan pipeline:** ingest, map the project, run the scanners, triage the risky files, audit each one with an LLM, verify and judge, then rank and grade the findings.
- **My own Semgrep rule pack:** 42 rules for JavaScript, TypeScript and Python (SQL and command injection, XSS, path traversal, SSRF, unverified JWTs, hard-coded secrets, async `forEach` and more). Every rule has passing and failing test cases, checked in CI with `semgrep --test`.
- **The model as judge.** Each scanner hit goes into the audit prompt as a hint, and the verification call rules on every one. When the model and a rule report the same bug, they merge into one finding marked "model + semgrep". Dismissed hits stay out of the grade but are listed with the model's reason.
- **Semgrep Pro when self-hosted.** With a Semgrep token, local scans switch to the Pro engine, which follows data across functions and adds Semgrep's Pro and Registry rules.
- **A Docker sandbox**, also self-hosted only, that builds and runs the app to catch build, boot and runtime errors.
- **A public mode** that accepts snippets only, masks secrets in the report, uses report IDs that can't be guessed, sends security headers, and enforces size limits, per-IP and daily caps. Results expire after 24 hours.
- **AWS deployment with Terraform:** CloudFront and S3 for the page, a small Lambda for the API, and a worker Lambda that runs from an arm64 container image in ECR (Semgrep is too big for a zip Lambda). GitHub Actions builds the image on an arm64 runner and deploys on every push.

## The hard parts

- **A failure that looked like success.** A failed model call once showed "grade A, spotless". Now a cut-off reply is salvaged, a failed one is retried, and if it still fails the report says so. It never shows a clean grade it didn't earn.
- **Cost.** A snippet scan used about 12 model calls. Folding the profile step into the audit and batching verification brought it to 2. Judging the scanner hits rides in that same verification call, so adding Semgrep cost no extra calls.
- **Licensing.** Semgrep's own rules may only be used on your own code, not offered to others as a service. So the hosted demo runs only my rule pack, and the code locks public mode to it whatever the settings say. The Pro engine and the Docker sandbox show on the site as "self-hosted only".
- **Duplicates across tools.** The same bug came back from the model, my rules and Semgrep's rules under different CWE numbers. Now the judge marks duplicates itself, and findings with different CWEs only merge when their titles share a keyword.
- **False positives.** Scanners and models both over-report. The second pass argues against each serious finding, and only the ones that survive are reported.

## Results

On a sample of AI-written code with planted bugs (SQL injection, a forgeable JWT login, hardcoded live keys, and the $0 async checkout):

- **Found every planted bug**, each with its line number and a fix.
- **On the live demo:** Semgrep raised 16 hits, the model judged all of them along with its own findings, and the report came to 12 findings with grade F. Every one of the 10 most serious was found by both the model and a rule.
- **Semgrep Pro, run locally:** it caught a command injection that passes through two helper functions, which the free engine missed (38 hits against 23).
- **2 model calls** per snippet, down from about 12.

Measured in November 2026, one run each.

## What I'd do next

- A larger seeded-bug benchmark, so the detection rate is a number across many samples, not one.
- A faster cold start for the worker: the first scan after the site has been idle takes about 40 s to start.
