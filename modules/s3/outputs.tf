output "gitlab_runner_config_file" {
  value = "${aws_s3_bucket_object.gl_runner_config.key}"
}

output "s3_gitlab_runner_bucket" {
  value = "${aws_s3_bucket.gl_runner.id}"
}
