variable "aws_region" {
  description = "Region for the S3 bucket. CloudFront itself is global."
  type        = string
  default     = "ap-south-1"
}

variable "github_repo" {
  description = "GitHub repository allowed to deploy, as owner/name (for example yourname/portfolio-website)."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9-]+/[A-Za-z0-9._-]+$", var.github_repo))
    error_message = "github_repo must look like owner/name."
  }
}

variable "github_branch" {
  description = "Only pushes to this branch can deploy."
  type        = string
  default     = "main"
}

variable "github_sub_prefix" {
  description = "The repo's OIDC subject prefix when GitHub uses immutable subjects, e.g. repo:owner@123/name@456. Read it with: gh api repos/OWNER/NAME/actions/oidc/customization/sub (field sub_claim_prefix)."
  type        = string
  default     = ""
}

variable "create_github_oidc_provider" {
  description = "Set to false if your AWS account already has the GitHub OIDC provider (token.actions.githubusercontent.com), for example from another project."
  type        = bool
  default     = true
}

variable "price_class" {
  description = "CloudFront edge locations. PriceClass_200 includes India; PriceClass_100 does not."
  type        = string
  default     = "PriceClass_200"
}

variable "custom_domain" {
  description = "Optional custom domain for the site, e.g. arshdeepsingh.is-a.dev. Empty = only the *.cloudfront.net address."
  type        = string
  default     = ""
}

variable "attach_custom_domain" {
  description = "Set to true once the custom_domain certificate is ISSUED (its validation DNS record is live). Step 2 of domain.tf."
  type        = bool
  default     = false
}
