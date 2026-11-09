---
title: FitCheck
pitch: Paste a job description; every requirement is checked against real code, or marked unverified.
order: 2
featured: true
status: live
tags: [GenAI]
stack: [LangGraph, FastAPI, RAG, pgvector, Evals]
metric: "<b>100% accuracy</b> · 0% false claims"
metricDate: "2026-11"
demo: fit
links:
  code: "https://github.com/arshdeep3010/fitcheck"
  demo: "https://f7yxpsphemzbymhpc5uu6qzz4q0oilnj.lambda-url.ap-south-1.on.aws/"
  video: ""
---

## The problem

CVs claim skills, and nobody can check them quickly. A recruiter reads "RAG, LangGraph, FastAPI" and has to take it on trust.

## What I built

- **A LangGraph pipeline** that parses a job description into requirements, retrieves matching code from my repositories (RAG over pgvector with NVIDIA embeddings), and scores every requirement in one model call.
- **Grounding rules in code.** A "met" must cite a chunk that was actually retrieved for that requirement, with enough confidence. Otherwise it's "unverified", never a guess. If a model is down, every row is unverified and nothing is claimed.
- **The CV is a claim, not proof.** It's searched only for rows the code didn't prove, shown as "Stated on CV" with its own badge and box, and counted in a separate score.
- **Citations that stay valid.** The app syncs with GitHub at startup and every 30 minutes, re-embeds only repos with a new commit, and links every proof to a commit permalink.
- **Public-demo safety:** size limits, a per-IP and a daily cap, nothing stored, and a rate limiter that a forged `X-Forwarded-For` can't dodge. 73 tests.

## The hard parts

- **Saying "I don't know".** Making unverified the default, and requiring a retrieved chunk to move off it, is what keeps false claims at zero.
- **A vector search that came back empty.** HNSW finds its nearest rows and then filters, so the CV search (1% of rows) returned 0–2 of the 3 rows asked for. A small test table never showed it. I reproduced it by forcing the index plan, then fixed it with exact search for the CV and iterative scan for code.
- **A stale label.** One eval run dropped to 96%: the model said I know React, and my label said no. The GitHub sync had added a repo with a real React frontend, so the model was right. Now every eval run records what was indexed.

## Results

On 25 hand-labelled requirements, including near misses like Docker vs Kubernetes and React vs Angular:

| | Accuracy | False claims |
|---|---|---|
| FitCheck (Nemotron scorer) | 100% | 0% |
| Keyword baseline | 52% | 54% |

Measured on 7 Nov 2026 over 719 chunks from 12 repositories and the CV. 25 requirements is a small set, so treat it as a check, not a benchmark.

## What I'd do next

- Grow the labelled set to 30 or more job descriptions, with a prompt-injection case.
- Add a similarity floor to retrieval and compare a calibrated decision model with the LLM scorer.
