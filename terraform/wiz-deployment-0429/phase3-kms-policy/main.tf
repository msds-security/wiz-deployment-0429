# ============================================================================
# WIZ DETECTION TEST - Phase 3
# KMS key with a resource policy granting Encrypt/Decrypt to specified IAM
# role ARNs (validates KMS key-policy grant detection).
# ============================================================================

locals {
  common_tags = {
    Project          = var.project_name
    WizDeploymentRun = var.deployment_id
    Phase            = "phase3-kms-policy"
    Purpose          = "wiz-detection-test"
  }

  # Fall back to the account root if the caller didn't pass any role ARNs,
  # so the policy is always syntactically valid.
  effective_trusted_arns = length(var.trusted_role_arns) > 0 ? var.trusted_role_arns : ["arn:aws:iam::${var.account_id}:root"]
}

resource "aws_kms_key" "test" {
  description             = "Wiz detection test - resource-policy grant to trusted roles"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags                    = local.common_tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableRootAdmin"
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${var.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowTrustedRolesEncryptDecrypt"
        Effect    = "Allow"
        Principal = { AWS = local.effective_trusted_arns }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "test" {
  name          = "alias/${var.project_name}-${var.deployment_id}"
  target_key_id = aws_kms_key.test.key_id
}
