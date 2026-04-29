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

# Override before running: an account ID you control (or a known external test account).
# Set via TF_VAR_external_account_id or -var=external_account_id=...
variable "external_account_id" {
  description = "External AWS account ID granted GetSecretValue on the secret"
  type        = string
  default     = "000000000000"
}
