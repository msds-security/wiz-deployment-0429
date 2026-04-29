# ============================================================================
# WIZ DETECTION TEST - Phase 1 (Deny-except-role variant, Option B)
# Bucket policy explicitly denies s3:* for all principals EXCEPT a list of
# trusted IAM principals: always jenkins-ci (so terraform can manage the
# bucket), plus an optional additional role (the actual CIEM test subject).
# ============================================================================

locals {
  bucket_name    = "${var.project_name}-public-${var.account_id}"
  jenkins_ci_arn = "arn:aws:iam::${var.account_id}:user/jenkins-ci"

  common_tags = {
    Project          = var.project_name
    WizDeploymentRun = var.deployment_id
    Phase            = "phase1-s3-deny-except-role"
    Purpose          = "wiz-detection-test"
  }

  # Trust list: jenkins-ci is always included (lockout protection).
  # If trusted_role_arn is supplied, it's appended.
  trusted_principal_arns = distinct(compact(concat(
    [local.jenkins_ci_arn],
    [var.trusted_role_arn]
  )))
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
      Sid       = "DenyAllExceptTrustedPrincipals"
      Effect    = "Deny"
      Principal = "*"
      Action    = "s3:*"
      Resource = [
        aws_s3_bucket.public.arn,
        "${aws_s3_bucket.public.arn}/*",
      ]
      Condition = {
        StringNotEquals = {
          "aws:PrincipalArn" = local.trusted_principal_arns
        }
      }
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.public]
}
