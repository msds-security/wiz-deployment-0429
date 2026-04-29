output "secret_name" {
  value = aws_secretsmanager_secret.cross_account.name
}

output "secret_arn" {
  value = aws_secretsmanager_secret.cross_account.arn
}

output "trusted_external_account" {
  value = var.external_account_id
}
