output "instance_id" { value = aws_instance.web.id }
output "elastic_ip" { value = aws_eip.web.public_ip }
output "iam_role_name" { value = aws_iam_role.ec2.name }
output "security_group_id" { value = aws_security_group.web.id }
