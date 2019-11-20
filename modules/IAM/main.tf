resource "aws_iam_role" "gl_runner" {
  name = "${var.app}-role"

  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attach" {
  role = "${aws_iam_role.gl_runner.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "s3_role_policy_attach" {
  role = "${aws_iam_role.gl_runner.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "docker" {
  name = "${var.app}-profile"
  role = "${aws_iam_role.gl_runner.name}"
}
