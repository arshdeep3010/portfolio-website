# Optional custom domain, e.g. arshdeepsingh.is-a.dev.
#
# It goes live in two steps, because AWS only issues the certificate once a
# DNS record proves you control the name:
#   1. Set custom_domain and apply. Terraform requests the certificate and
#      prints the validation record (output custom_domain_dns_records).
#      Add both records (validation + site CNAME) at your DNS provider.
#   2. Once the certificate shows ISSUED, set attach_custom_domain = true and
#      apply again. CloudFront then answers on the domain.

# CloudFront only accepts certificates from us-east-1.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project   = "portfolio-website"
      ManagedBy = "terraform"
    }
  }
}

resource "aws_acm_certificate" "site" {
  count             = var.custom_domain == "" ? 0 : 1
  provider          = aws.us_east_1
  domain_name       = var.custom_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# Waits (briefly) for the certificate to be ISSUED before CloudFront uses it.
resource "aws_acm_certificate_validation" "site" {
  count                   = var.custom_domain != "" && var.attach_custom_domain ? 1 : 0
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.site[0].arn
  validation_record_fqdns = [for o in aws_acm_certificate.site[0].domain_validation_options : o.resource_record_name]

  timeouts {
    create = "10m"
  }
}

locals {
  use_custom_domain = var.custom_domain != "" && var.attach_custom_domain
}
