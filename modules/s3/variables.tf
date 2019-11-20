variable "app" {}

variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "region" {}

variable "vpc_id" {}

variable "subnet_ids" {}

variable "subnet_zone_mapping" {
  type = "map"
}

variable "s3_bucket_prefix" {}

variable "gitlab_runner_sg" {}

variable "gitlab_url" {}

variable "gitlab_runner_name" {}
