# ============================================================================
# WIZ DETECTION TEST - Phase 1
# Intentionally creates an S3 bucket with PUBLIC READ access to validate that
# Wiz detects public exposure. Do not place real data in this bucket.
# ============================================================================

locals {
  bucket_name = "${var.project_name}-public-${var.account_id}"
  common_tags = {
    Project          = var.project_name
    WizDeploymentRun = var.deployment_id
    Phase            = "phase1-s3-public"
    Purpose          = "wiz-detection-test"
  }
}

resource "aws_s3_bucket" "public" {
  bucket        = local.bucket_name
  force_destroy = true
  tags          = local.common_tags
}

resource "aws_s3_bucket_ownership_controls" "public" {
  bucket = aws_s3_bucket.public.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Disables public access blocks so the bucket policy below actually takes effect.
resource "aws_s3_bucket_public_access_block" "public" {
  bucket                  = aws_s3_bucket.public.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Anonymous public read on all objects.
resource "aws_s3_bucket_policy" "public" {
  bucket = aws_s3_bucket.public.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.public.arn}/*"
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.public]
}
