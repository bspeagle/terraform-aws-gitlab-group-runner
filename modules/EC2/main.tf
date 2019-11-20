data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }
}

data "template_file" "user_data_runner" {
  template = "${file("../files/user_data/user_data_runner.tpl")}"

  vars = {
    s3_gitlab_runner_bucket = "${var.s3_gitlab_runner_bucket}"
    gitlab_url = "${var.gitlab_url}"
    gitlab_api_token = "${var.gitlab_api_token}"
    gitlab_runner_reg_token = "${var.gitlab_runner_reg_token}"
    gitlab_group_id = "${var.gitlab_group_id}"
    gitlab_runner_name = "${var.gitlab_runner_name}"
    gitlab_runner_config_file = "${var.gitlab_runner_config_file}"
  }
}

resource "aws_launch_configuration" "gitlab_runner" {
  image_id = "${data.aws_ami.ubuntu.id}"
  instance_type = "t3.micro"
  security_groups = ["${var.gitlab_runner_sg_id}"]
  iam_instance_profile = "${var.iam_profile_name}"
  user_data = "${data.template_file.user_data_runner.rendered}"
  key_name = "${var.key_pair}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "gitlab_rubber" {
  max_size = 1
  min_size = 1
  health_check_grace_period = 30
  health_check_type = "ELB"
  desired_capacity = 1
  launch_configuration = "${aws_launch_configuration.gitlab_runner.name}"
  vpc_zone_identifier = "${var.subnet_ids}"

  tag {
    key = "Name"
    value = "${var.app}-primary"
    propagate_at_launch = true
  }

  tag {
    key = "App"
    value = "${var.app}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
