# ============================================================================
# WIZ DETECTION TEST - Phase 2
# Secrets Manager secret with a resource policy granting GetSecretValue to an
# external AWS account (validates cross-account access detection).
# Do not store real credentials in this secret.
# ============================================================================

locals {
  common_tags = {
    Project          = var.project_name
    WizDeploymentRun = var.deployment_id
    Phase            = "phase2-secret-cross-account"
    Purpose          = "wiz-detection-test"
  }
}

resource "aws_secretsmanager_secret" "cross_account" {
  name                    = "${var.project_name}-cross-account-${var.deployment_id}"
  description             = "Wiz detection test - cross-account read"
  recovery_window_in_days = 0 # immediate destroy, so re-tests don't conflict
  tags                    = local.common_tags
}

resource "aws_secretsmanager_secret_version" "cross_account" {
  secret_id     = aws_secretsmanager_secret.cross_account.id
  secret_string = jsonencode({ test = "not-a-real-secret" })
}

# Grants cross-account read to the external account root principal.
resource "aws_secretsmanager_secret_policy" "cross_account" {
  secret_arn = aws_secretsmanager_secret.cross_account.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCrossAccountRead"
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${var.external_account_id}:root"
      }
      Action = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Resource = "*"
    }]
  })
}
