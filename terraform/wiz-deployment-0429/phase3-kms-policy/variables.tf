variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "account_id" {
  type = string
}

variable "project_name" {
  type    = string
  default = "wiz-deployment-0429"
}

variable "deployment_id" {
  description = "Per-build marker, set from Jenkins as TF_VAR_deployment_id=build-<N>"
  type        = string
  default     = "manual"
}

# Override before running with the role ARNs you want Wiz to flag as KMS-grant recipients.
# Example: TF_VAR_trusted_role_arns='["arn:aws:iam::562517367791:role/SomeRole"]'
variable "trusted_role_arns" {
  description = "IAM role ARNs granted kms:Encrypt/Decrypt on the test key"
  type        = list(string)
  default     = []
}
