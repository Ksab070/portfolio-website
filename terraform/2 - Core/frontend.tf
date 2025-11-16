# Create the bucket
resource "aws_s3_bucket" "bucket" {
  bucket = local.s3_bucket_name
  tags   = merge(local.aws_tags, local.environment)
}

# Upload frontend code to the bucket
resource "aws_s3_object" "upload_frontend" {
  for_each = { for file in local.frontend_files : file => file }

  bucket = aws_s3_bucket.bucket.id
  key    = each.key
  source = "${local.frontend_path}/${each.key}"
  etag   = filemd5("${local.frontend_path}/${each.key}")

  # Detect Content-Type automatically using MIME lookup, copied from chatgpt :)
  content_type = lookup(
    {
      html  = "text/html"
      css   = "text/css"
      js    = "application/javascript"
      json  = "application/json"
      png   = "image/png"
      jpg   = "image/jpeg"
      jpeg  = "image/jpeg"
      svg   = "image/svg+xml"
      woff  = "font/woff"
      woff2 = "font/woff2",
      pdf   = "application/pdf",
      py    = "text/x-python"
    },
    regex("[^.]+$", each.value),
    "application/octet-stream"
  )
  tags = merge(local.aws_tags, local.environment)
}


# Cloudfront starts here #

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution
# The below policy restricts s3 bucket access only from the CF distribution 
data "aws_iam_policy_document" "origin_bucket_policy" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}

data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

# Modify the s3 bucket policy for the cloudfront distribution
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.bucket
  policy = data.aws_iam_policy_document.origin_bucket_policy.json
}

# Create a new OAC 
resource "aws_cloudfront_origin_access_control" "default" {
  name                              = "default-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Create the cloudfront distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled             = true
  default_root_object = "index.html"

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.acm-cert-for-app-domain.arn
    ssl_support_method  = "sni-only"
  }

  # Add an alias to this  
  aliases = [local.app-domain]

  # Virtually adding no restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  ordered_cache_behavior {
    path_pattern           = "/api"
    target_origin_id       = local.apigateway_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    cache_policy_id = data.aws_cloudfront_cache_policy.caching_disabled.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Front-end origin (s3 bucket)
  origin {
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = local.s3_origin_id
    domain_name              = aws_s3_bucket.bucket.bucket_regional_domain_name
  }

  # API - gateway origin 
  origin {
    domain_name = replace(aws_apigatewayv2_api.views-api.api_endpoint, "https://", "")
    origin_id   = local.apigateway_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

  }

  tags = merge(local.aws_tags, local.environment)

  depends_on = [aws_s3_bucket.bucket, aws_apigatewayv2_api.views-api]

}

resource "aws_route53_record" "cname-cf-distro-from-appdomain" {
  zone_id = data.aws_route53_zone.app-domain.zone_id
  name    = local.app-domain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}


