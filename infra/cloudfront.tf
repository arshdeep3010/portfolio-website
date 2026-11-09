# CloudFront serves the site over HTTPS from edge locations.
# S3 website endpoints are HTTP-only, which is why the bucket stays
# private and CloudFront sits in front of it.

locals {
  s3_origin_id = "site-bucket"

  # AWS managed policies (stable IDs, same in every account).
  cache_policy_caching_optimized   = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  response_headers_security_policy = "67f7725c-6f97-4210-82d7-5512b31e9d03"
}

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "portfolio-site-oac"
  description                       = "CloudFront access to the portfolio bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Astro builds /projects/agentops/ as /projects/agentops/index.html.
# S3 (through OAC) does not resolve directory indexes, so this rewrites
# "/projects/agentops" and "/projects/agentops/" to the index.html file.
resource "aws_cloudfront_function" "directory_index" {
  name    = "portfolio-directory-index"
  runtime = "cloudfront-js-2.0"
  comment = "Rewrite folder URLs to index.html"
  publish = true
  code    = <<-JS
    function handler(event) {
      var request = event.request;
      var uri = request.uri;
      if (uri.endsWith('/')) {
        request.uri = uri + 'index.html';
      } else if (uri.split('/').pop().indexOf('.') === -1) {
        request.uri = uri + '/index.html';
      }
      return request;
    }
  JS
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Portfolio website"
  default_root_object = "index.html"
  price_class         = var.price_class
  http_version        = "http2and3"

  origin {
    origin_id                = local.s3_origin_id
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id           = local.s3_origin_id
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    compress                   = true
    cache_policy_id            = local.cache_policy_caching_optimized
    response_headers_policy_id = local.response_headers_security_policy

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.directory_index.arn
    }
  }

  # Missing files come back from S3 as 403 (the bucket is private),
  # so both 403 and 404 show the site's own 404 page.
  custom_error_response {
    error_code            = 403
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 60
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 60
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # The *.cloudfront.net address always works. With a custom domain attached
  # (see domain.tf), CloudFront also answers on it with its own certificate.
  aliases = local.use_custom_domain ? [var.custom_domain] : []

  viewer_certificate {
    cloudfront_default_certificate = local.use_custom_domain ? null : true
    acm_certificate_arn            = local.use_custom_domain ? aws_acm_certificate_validation.site[0].certificate_arn : null
    ssl_support_method             = local.use_custom_domain ? "sni-only" : null
    minimum_protocol_version       = local.use_custom_domain ? "TLSv1.2_2021" : null
  }
}
