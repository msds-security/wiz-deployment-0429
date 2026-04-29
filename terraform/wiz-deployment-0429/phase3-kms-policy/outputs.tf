output "key_id" {
  value = aws_kms_key.test.key_id
}

output "key_arn" {
  value = aws_kms_key.test.arn
}

output "key_alias" {
  value = aws_kms_alias.test.name
}

output "trusted_role_arns" {
  value = local.effective_trusted_arns
}
