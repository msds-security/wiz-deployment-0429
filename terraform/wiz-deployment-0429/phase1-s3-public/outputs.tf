output "bucket_name" {
  value = aws_s3_bucket.public.id
}

output "bucket_arn" {
  value = aws_s3_bucket.public.arn
}

output "trusted_principal_arns" {
  value = local.trusted_principal_arns
}

output "policy_summary" {
  value = "Deny s3:* for all principals not in ${jsonencode(local.trusted_principal_arns)}"
}
