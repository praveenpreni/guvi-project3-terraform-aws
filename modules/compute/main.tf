resource "aws_security_group" "web" {
  name_prefix = "${var.name}-web-"
  description = "HTTP web server; no inbound SSH"
  vpc_id      = var.vpc_id
}
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}
resource "aws_vpc_security_group_egress_rule" "http" {
  security_group_id = aws_security_group.web.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}
resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.web.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}
data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "ec2" {
  name               = "${var.name}-ec2"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}
data "aws_iam_policy_document" "read_assets" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${var.bucket_arn}/assets/*"]
  }
}
resource "aws_iam_role_policy" "read_assets" {
  role   = aws_iam_role.ec2.id
  policy = data.aws_iam_policy_document.read_assets.json
}
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name}-ec2"
  role = aws_iam_role.ec2.name
}
resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.web.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2.name
  associate_public_ip_address = false
  user_data                   = file("${path.module}/user-data.sh")
  user_data_replace_on_change = true
  metadata_options {
    http_tokens = "required"
  }
  root_block_device {
    encrypted   = true
    volume_size = 8
    volume_type = "gp3"
  }
  tags = { Name = "${var.name}-web" }
  depends_on = [
    aws_vpc_security_group_egress_rule.http,
    aws_vpc_security_group_egress_rule.https,
    aws_iam_role_policy.read_assets
  ]
}
resource "aws_eip" "web" {
  domain   = "vpc"
  instance = aws_instance.web.id
  tags     = { Name = "${var.name}-web" }
}
