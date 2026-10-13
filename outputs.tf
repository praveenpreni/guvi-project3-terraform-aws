output "vpc_id" {
  value = module.networking.vpc_id
}
output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}
output "ec2_instance_id" {
  value = module.compute.instance_id
}
output "elastic_ip" {
  value = module.compute.elastic_ip
}
output "application_url" {
  value = "http://${module.compute.elastic_ip}"
}
output "s3_bucket_name" {
  value = aws_s3_bucket.application.id
}
output "iam_role_name" {
  value = module.compute.iam_role_name
}
output "security_group_id" {
  value = module.compute.security_group_id
}
