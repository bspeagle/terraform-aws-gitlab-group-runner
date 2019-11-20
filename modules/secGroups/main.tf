resource "aws_security_group" "gl_runner" {
  name = "${var.app}-sg"
  description = "sg for gitlab runner"
  vpc_id = "${var.vpc_id}"

  ingress {
    description = "docker ssl"
    from_port = 2376
    to_port = 2376
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "docker"
    from_port = 2375
    to_port = 2375
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app}-sg"
    App = "${var.app}"
  }
}

resource "aws_security_group_rule" "ssh_access" {
  security_group_id = "${aws_security_group.gl_runner.id}"
  count = var.ssh_access == true ? 1 : 0
  type = "ingress"
  description = "SSH"
  from_port = 22
  to_port = 22
  cidr_blocks = ["0.0.0.0/0"]
  protocol = "tcp"
}
