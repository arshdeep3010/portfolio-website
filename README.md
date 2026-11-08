# Arshdeep Singh: portfolio

My portfolio site: **https://dy880hqri6uqu.cloudfront.net**

It's a static Astro site on AWS S3 + CloudFront. Every push to `main` builds and deploys it in about a minute, with no AWS keys stored in GitHub.

## Stack

| Part | What |
| --- | --- |
| Site | [Astro 5](https://astro.build), static output, no client framework |
| Content | One Markdown file per project in `src/content/projects/`, checked by a typed schema (a bad file fails the build) |
| Hosting | Private S3 bucket behind CloudFront (Origin Access Control, HTTPS only, HSTS) |
| Infra | Terraform in `infra/`: bucket, distribution, URL-rewrite function, deploy role |
| CI/CD | GitHub Actions: build, `s3 sync`, CloudFront invalidation |
| Auth | GitHub OIDC to an IAM role that only `main` of this repo can assume, and that can only write this bucket and invalidate this distribution |

## How a deploy works

```
push to main
  -> GitHub Actions: npm ci, astro build   (the schema check runs here)
  -> assume AWS role via OIDC              (short-lived credentials, no stored keys)
  -> s3 sync                               (hashed assets cached 1 year, HTML revalidated)
  -> CloudFront invalidation, wait until live
```

Changes that only touch `infra/` or this README don't trigger a deploy. Infra changes are applied with `terraform apply` (see [infra/DEPLOY.md](infra/DEPLOY.md)).

## Run locally

```bash
npm install
npm run dev        # http://localhost:4321
npm run build      # output in dist/
```

## Adding a project

Add a Markdown file to `src/content/projects/`. Its front matter holds the title, pitch, stack, metric (with the date it was measured) and links. Empty `code` / `demo` links show as "soon" instead of a dead link. Push to `main` and it goes live.
