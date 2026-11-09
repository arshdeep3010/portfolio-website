output "site_url" {
  description = "Public HTTPS address of the site."
  value       = "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "s3_bucket" {
  description = "Set as the S3_BUCKET repository variable in GitHub."
  value       = aws_s3_bucket.site.bucket
}

output "cloudfront_distribution_id" {
  description = "Set as the CLOUDFRONT_DISTRIBUTION_ID repository variable in GitHub."
  value       = aws_cloudfront_distribution.site.id
}

output "deploy_role_arn" {
  description = "Set as the AWS_ROLE_ARN repository variable in GitHub."
  value       = aws_iam_role.deploy.arn
}

output "aws_region" {
  description = "Set as the AWS_REGION repository variable in GitHub."
  value       = var.aws_region
}

output "custom_domain_dns_records" {
  description = "DNS records to add for the custom domain: the certificate check and the site itself."
  value = var.custom_domain == "" ? null : {
    certificate_validation = [for o in aws_acm_certificate.site[0].domain_validation_options : {
      name  = o.resource_record_name
      type  = o.resource_record_type
      value = o.resource_record_value
    }]
    site = {
      name  = var.custom_domain
      type  = "CNAME"
      value = aws_cloudfront_distribution.site.domain_name
    }
  }
}

output "custom_domain_certificate_status" {
  description = "PENDING_VALIDATION until the validation record is live, then ISSUED."
  value       = var.custom_domain == "" ? null : aws_acm_certificate.site[0].status
}
