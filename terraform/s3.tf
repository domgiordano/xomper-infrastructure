resource "aws_s3_bucket" "web_app" {
  bucket        = local.domain_name
  force_destroy = true
  tags = merge(local.standard_tags, tomap({ "name" = local.domain_name }))
}

# s3 declare bucket ownership controls (disable ACLs)
resource "aws_s3_bucket_ownership_controls" "web_app" {
  bucket = aws_s3_bucket.web_app.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# s3 block public access
resource "aws_s3_bucket_public_access_block" "web_app" {
  bucket = aws_s3_bucket.web_app.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# s3 bucket versioning
resource "aws_s3_bucket_versioning" "web_app" {
  bucket = aws_s3_bucket.web_app.id
  versioning_configuration {
    status =   "Enabled"
  }
}

# s3 bucket encryption (KMS)
resource "aws_s3_bucket_server_side_encryption_configuration" "web_app" {
  bucket = aws_s3_bucket.web_app.id
  rule{
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_alias.web_app.target_key_arn
    }
  }
}

# automatically delete old file versions
resource "aws_s3_bucket_lifecycle_configuration" "web_app" {
  bucket = aws_s3_bucket.web_app.id
  rule {
    id = "delete-older-than-latest-3-versions"
    noncurrent_version_expiration {
      newer_noncurrent_versions = 3
      noncurrent_days = 1  # must specify days > 0
    }
    status = "Enabled"
  }
  rule {
    id = "delete-old-versions-after-90-days"
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    status = "Enabled"
  }
}

# Grant CloudFront OAC access to the bucket
resource "aws_s3_bucket_policy" "web_app" {
  bucket   = aws_s3_bucket.web_app.id
  policy   = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "AllowCloudFrontAccess",
          "Effect": "Allow",
          "Principal": {
            "Service": "cloudfront.amazonaws.com"
          },
          "Action": "s3:GetObject",
          "Resource": "${aws_s3_bucket.web_app.arn}/*",
          "Condition": {
            "StringEquals": {
              "AWS:SourceArn": aws_cloudfront_distribution.web_app.arn
            }
          }
        }
      ]
    }
  )
}
