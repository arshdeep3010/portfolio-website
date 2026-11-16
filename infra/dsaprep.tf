# Optional: serve a private app (Prep Desk, a separate repo and stack) at <domain>/dsaprep.
#   /dsaprep, /dsaprep/*   -> that app's page, from its own private bucket
#   /dsaprep/api/*         -> that app's API (a Lambda function URL)
# Off unless both dsaprep_* variables are set. The other stack must also allow this
# distribution (its bucket policy and Lambda permissions).

variable "dsaprep_bucket_domain" {
  description = "Regional domain of the Prep Desk page bucket (its output site_bucket_domain). Empty = no /dsaprep route."
  type        = string
  default     = ""
}

variable "dsaprep_api_host" {
  description = "Host of the Prep Desk function URL (its output api_host). Empty = no /dsaprep route."
  type        = string
  default     = ""
}

locals {
  dsaprep = var.dsaprep_bucket_domain != "" && var.dsaprep_api_host != ""

  # AWS managed policies (stable IDs, same in every account).
  cache_policy_caching_disabled              = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  origin_request_all_viewer_except_host_head = "b689b0a8-53d0-40ab-baf2-68738e2966ac"

  # Evaluated in this order: the API first, then the page.
  dsaprep_page_paths = local.dsaprep ? ["/dsaprep", "/dsaprep/*"] : []
}

# The function URL only accepts requests CloudFront has signed.
resource "aws_cloudfront_origin_access_control" "dsaprep_api" {
  count                             = local.dsaprep ? 1 : 0
  name                              = "portfolio-dsaprep-lambda"
  description                       = "Portfolio domain signs requests to the Prep Desk API"
  origin_access_control_origin_type = "lambda"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# The app is one page: every /dsaprep URL that isn't the API is its index.html.
resource "aws_cloudfront_function" "dsaprep_page" {
  count   = local.dsaprep ? 1 : 0
  name    = "portfolio-dsaprep-page"
  runtime = "cloudfront-js-2.0"
  comment = "Serve the Prep Desk page for /dsaprep URLs"
  publish = true
  code    = <<-JS
    function handler(event) {
      event.request.uri = '/index.html';
      return event.request;
    }
  JS
}
