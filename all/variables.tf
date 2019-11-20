variable "access_key" {}

variable "secret_key" {}

variable "region" {}

variable "app" {}

variable "vpc_id" {}

variable "subnet_zone_mapping" {
  type = "map"

  default = {
    us-east-1a = "a"
    us-east-1b = "b"
    us-east-1c = "c"
    us-east-1d = "d"
    us-east-1e = "e"
    us-east-1f = "f"
  }
}


variable "s3_bucket_prefix" {}

variable "ssh_access" {}

variable "key_pair" {}

variable "gitlab_url" {}

variable "gitlab_runner_reg_token" {}

variable "gitlab_api_token" {}

variable "gitlab_group_id" {}

variable "gitlab_runner_name" {}
