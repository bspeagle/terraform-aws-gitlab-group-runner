provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

# # Uncomment if you want to use remote state files in S3. You should. It's a good idear.
# # When using please refer to the doc for config detals: https://www.terraform.io/docs/backends/types/s3.html
# terraform {
#   backend "s3" {
#     bucket = "SOMETHING-ABOUT-STATE-FILES"
#     key = "gl-runner/terraform.tfstate"
#     region = "us-east-1"
#     dynamodb_table = "gl-runner-tf-state-lock"
#   }
# }

data "aws_vpc" "default" {
  count = var.vpc_id != "" ? 0 : 1
  default = true
}

data "aws_vpc" "custom" {
  count = var.vpc_id != "" ? 1 : 0
  id = var.vpc_id
}

data "aws_subnet_ids" "default" {
  vpc_id = var.vpc_id != "" ? data.aws_vpc.custom[0].id : data.aws_vpc.default[0].id
}

module "secGroups" {
  source = "../modules/secGroups"
  app = "${var.app}"
  vpc_id = var.vpc_id != "" ? data.aws_vpc.custom[0].id : data.aws_vpc.default[0].id
  ssh_access = "${var.ssh_access}"
}

module "s3" {
  source = "../modules/s3"
  aws_access_key = "${var.access_key}"
  aws_secret_key = "${var.secret_key}"
  region = "${var.region}"
  app = "${var.app}"
  vpc_id = var.vpc_id != "" ? data.aws_vpc.custom[0].id : data.aws_vpc.default[0].id
  subnet_ids = "${data.aws_subnet_ids.default.ids}"
  subnet_zone_mapping = "${var.subnet_zone_mapping}"
  s3_bucket_prefix = "${var.s3_bucket_prefix}"
  gitlab_runner_sg = "${module.secGroups.gitlab_runner_sg}"
  gitlab_url = "${var.gitlab_url}"
  gitlab_runner_name = "${var.gitlab_runner_name}"
}

module "IAM" {
  source = "../modules/IAM"
  app = "${var.app}"
}

module "ec2" {
  source = "../modules/EC2"
  region = "${var.region}"
  app = "${var.app}"
  vpc_id = var.vpc_id != "" ? data.aws_vpc.custom[0].id : data.aws_vpc.default[0].id
  subnet_ids = "${data.aws_subnet_ids.default.ids}"
  iam_profile_name = "${module.IAM.iam_profile_name}"
  s3_gitlab_runner_bucket = "${module.s3.s3_gitlab_runner_bucket}"
  ssh_access = "${var.ssh_access}"
  key_pair = "${var.key_pair}"
  gitlab_runner_sg_id = "${module.secGroups.gitlab_runner_sg_id}"
  gitlab_url = "${var.gitlab_url}"
  gitlab_api_token = "${var.gitlab_api_token}"
  gitlab_runner_reg_token = "${var.gitlab_runner_reg_token}"
  gitlab_group_id = "${var.gitlab_group_id}"
  gitlab_runner_name = "${var.gitlab_runner_name}"
  gitlab_runner_config_file = "${module.s3.gitlab_runner_config_file}"
}
