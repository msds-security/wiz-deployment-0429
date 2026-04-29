output "bucket_name" {
  value = aws_s3_bucket.public.id
}

output "bucket_arn" {
  value = aws_s3_bucket.public.arn
}
