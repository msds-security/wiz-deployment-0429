# ============================================================================
# WIZ DETECTION TEST - Phase 1 (Deny-except-role variant)
# Bucket policy explicitly denies s3:* for ALL principals EXCEPT a single
# trusted IAM principal (matched via aws:PrincipalArn). Public access blocks
# are re-enabled. Validates Wiz CIEM mapping of effective access.
# ============================================================================

locals {
  bucket_name = "${var.project_name}-public-${var.account_id}"
  common_tags = {
    Project          = var.project_name
    WizDeploymentRun = var.deployment_id
    Phase            = "phase1-s3-deny-except-role"
    Purpose          = "wiz-detection-test"
  }

  # Default trusted principal: jenkins-ci user. Keeping terraform's own
  # identity in the allow set prevents bucket-policy lockout on later applies.
  effective_trusted_arn = var.trusted_role_arn != "" ? var.trusted_role_arn : "arn:aws:iam::${var.account_id}:user/jenkins-ci"
}

resource "aws_s3_bucket" "public" {
  bucket        = local.bucket_name
  force_destroy = true
  tags          = local.common_tags
}

resource "aws_s3_bucket_ownership_controls" "public" {
  bucket = aws_s3_bucket.public.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "public" {
  bucket                  = aws_s3_bucket.public.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "public" {
  bucket = aws_s3_bucket.public.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "DenyAllExceptTrustedRole"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource = [
        aws_s3_bucket.public.arn,
        "${aws_s3_bucket.public.arn}/*",
      ]
      Condition = {
        StringNotEquals = {
          "aws:PrincipalArn" = local.effective_trusted_arn
        }
      }
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.public]
}
