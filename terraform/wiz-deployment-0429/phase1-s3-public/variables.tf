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
