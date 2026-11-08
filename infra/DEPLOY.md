# Deploy: S3 + CloudFront, updated on every push

```
git push (main) ──► GitHub Actions ──► build (Astro → dist/)
                         │
                         │ OIDC token, no stored AWS keys
                         ▼
                   IAM role (this repo + main branch only)
                         │
                         ├─► s3 sync  ──► private S3 bucket
                         └─► invalidate ─► CloudFront (HTTPS) ──► visitors
```

Terraform in this folder creates:

| Resource | Why |
|---|---|
| Private S3 bucket (versioned, old versions deleted after 30 days) | Holds the built site; versions allow rollback |
| CloudFront distribution + Origin Access Control | HTTPS, fast in India, only CloudFront can read the bucket |
| CloudFront Function | Serves `/projects/agentops/` from `index.html` |
| GitHub OIDC provider + `portfolio-site-deploy` role | Actions can upload to this bucket and clear this cache, nothing else |

**Cost:** close to zero. CloudFront's free tier covers 1 TB and 10 million requests a month; the S3 bucket holds a few MB.

## One-time setup

1. Install Terraform: `winget install Hashicorp.Terraform`, then open a new terminal.
2. Make sure the AWS CLI is signed in to your account: `aws sts get-caller-identity`.
3. Create the GitHub repo (`portfolio-website`) and push this folder to it.
4. In `infra/`, copy `terraform.tfvars.example` to `terraform.tfvars` and set `github_repo`.
   If the account already has the GitHub OIDC provider (`aws iam list-open-id-connect-providers`), set `create_github_oidc_provider = false`.
5. Create the infrastructure (CloudFront takes about 5 minutes):

   ```bash
   cd infra
   terraform init
   terraform apply
   ```

6. Copy the outputs into GitHub repository variables (not secrets; none of these are sensitive):

   ```bash
   gh variable set AWS_ROLE_ARN --body "$(terraform output -raw deploy_role_arn)"
   gh variable set AWS_REGION --body "$(terraform output -raw aws_region)"
   gh variable set S3_BUCKET --body "$(terraform output -raw s3_bucket)"
   gh variable set CLOUDFRONT_DISTRIBUTION_ID --body "$(terraform output -raw cloudfront_distribution_id)"
   ```

7. Run the workflow once from the Actions tab (Deploy site → Run workflow), or push any change. Open `terraform output -raw site_url`.

From then on, every push to `main` goes live in a minute or two.

## Notes

- **State:** `infra/terraform.tfstate` lives only on your machine (git-ignored). Keep a backup. Losing it doesn't break the site, but Terraform would no longer manage it.
- **The build** runs `npm ci && npm run build` and publishes `dist/`. A project file that breaks the content schema fails the build, so it never reaches the live site.
- **Custom domain URL:** once you have one, add a repository variable `SITE_URL` (e.g. `https://arshdeepsingh.dev`). The build uses it for canonical and Open Graph links.
- **Custom domain (later):** request an ACM certificate in `us-east-1`, add it and `aliases` to the distribution's `viewer_certificate`, and point the domain at CloudFront.
- **Tear down:** empty the bucket (including old versions), then `terraform destroy`.
