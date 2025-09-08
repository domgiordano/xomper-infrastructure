#-------------------------------------

# Set up CloudFront OAC and Distribution

#-------------------------------------

resource "aws_cloudfront_origin_access_control" "web_app" {
  name                              = "oac-for-${var.app_name}"  # this should be unique for teams that use the module multiple times
  description                       = "OAC for S3 bucket ${var.app_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
resource "aws_cloudfront_distribution" "web_app" {
  origin {
    domain_name              = aws_s3_bucket.web_app.bucket_regional_domain_name
    origin_id                = var.cloudfront_origin_id
    origin_path              = var.cloudfront_origin_path
    origin_access_control_id = aws_cloudfront_origin_access_control.web_app.id

  }
  web_acl_id          = aws_wafv2_web_acl.cloudfront_waf_web_acl.arn
  aliases             = [local.domain_name]
  retain_on_delete    = var.retain_on_delete
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = var.custom_error_response_page_path
  }
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.cloudfront_origin_id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.web_app.id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    min_ttl     = 0
    default_ttl = var.enable_cloudfront_cache ? 60 : 0
    max_ttl     = var.enable_cloudfront_cache ? 60 : 0
    viewer_protocol_policy = "redirect-to-https"
  }



  dynamic "restrictions" {
    for_each = var.us_canada_only ? [1] : []
    content {
      geo_restriction {
        restriction_type = "whitelist"
        locations        = ["US", "CA"]
      }
    }
  }
  viewer_certificate {
    # this automatically changes to false when deploying a custom cert / domain name
    # thus if left true it will refresh your cloudfront distro every time.
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate.web_app.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = var.minimum_tls_version
  }
  depends_on = [aws_acm_certificate.web_app, aws_acm_certificate_validation.web_app_validate]
}



resource "aws_cloudfront_response_headers_policy" "web_app" {
  name = "security-headers-policy-for-${var.app_name}"  # this should be unique for teams that use the module multiple times
  security_headers_config {
    content_type_options {
      override = true
    }
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      override                   = true
      preload                    = true
    }
    frame_options {
      frame_option = "SAMEORIGIN"
      override     = true
    }
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
    xss_protection {
      mode_block = true
      override   = true
      protection = true
    }
  }
}
