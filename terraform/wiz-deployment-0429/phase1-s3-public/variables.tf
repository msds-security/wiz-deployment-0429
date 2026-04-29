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

variable "trusted_role_arn" {
  description = "Additional IAM role ARN to trust alongside jenkins-ci. jenkins-ci is always trusted for pipeline lifecycle; this is the role being tested for Wiz CIEM detection. Empty = only jenkins-ci."
  type        = string
  default     = ""
}
