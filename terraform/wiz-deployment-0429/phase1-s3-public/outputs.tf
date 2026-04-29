output "bucket_name" {
  value = aws_s3_bucket.public.id
}

output "bucket_arn" {
  value = aws_s3_bucket.public.arn
}

output "trusted_role_arn" {
  value = local.effective_trusted_arn
}

output "policy_summary" {
  value = "Deny s3:* for all principals where aws:PrincipalArn != ${local.effective_trusted_arn}"
}
