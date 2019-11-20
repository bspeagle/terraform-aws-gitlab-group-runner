resource "aws_s3_bucket" "gl_runner" {
  bucket = "${var.s3_bucket_prefix}-${var.app}-config"
  acl = "private"

  tags = {
    Name = "${var.app}-config"
  }
}

data "template_file" "gl_runner_config" {
  template = "${file("../files/gl_runner/config.toml")}"

  vars = {
    aws_access_key = "${var.aws_access_key}"
    aws_secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
    vpc_id = "${var.vpc_id}"
    subnet_id = "${element(tolist(var.subnet_ids), 1)}"
    s3_gitlab_runner_bucket = "${aws_s3_bucket.gl_runner.id}"
    gitlab_runner_sg = "${var.gitlab_runner_sg}"
    gitlab_url = "${var.gitlab_url}"
    gitlab_runner_name = "${var.gitlab_runner_name}"
  }
}

resource "aws_s3_bucket_object" "gl_runner_config" {
  bucket = "${aws_s3_bucket.gl_runner.id}"
  key = "config.toml"
  content = "${data.template_file.gl_runner_config.rendered}"

  tags = {
    Name = "${var.app}-config-file"
    App = "${var.app}"
  }
}
