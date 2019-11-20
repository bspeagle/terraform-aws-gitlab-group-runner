output "gitlab_runner_sg" {
  value = "${aws_security_group.gl_runner.name}"
}

output "gitlab_runner_sg_id" {
  value = "${aws_security_group.gl_runner.id}"
}
