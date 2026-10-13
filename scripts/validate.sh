#!/usr/bin/env bash
set -euo pipefail
exec > >(tee validation.log) 2>&1
read_output() { jq -r --arg key "$1" '.[$key].value' outputs.json; }
INSTANCE=$(read_output ec2_instance_id)
BUCKET=$(read_output s3_bucket_name)
VPC=$(read_output vpc_id)
SG=$(read_output security_group_id)
ROLE=$(read_output iam_role_name)
IP=$(read_output elastic_ip)
aws ec2 wait instance-status-ok --instance-ids "$INSTANCE"
aws ec2 describe-instances --instance-ids "$INSTANCE" --output json > /tmp/instance.json
jq -e --arg ip "$IP" '[.Reservations[].Instances[] | select(.State.Name=="running" and .PublicIpAddress==$ip and .MetadataOptions.HttpTokens=="required")] | length == 1' /tmp/instance.json
aws ec2 describe-vpcs --vpc-ids "$VPC"
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC" > /tmp/subnets.json
jq -e '.Subnets | length == 2' /tmp/subnets.json
aws ec2 describe-addresses --public-ips "$IP"
aws ec2 describe-security-groups --group-ids "$SG" > /tmp/sg.json
jq -e '.SecurityGroups[0].IpPermissions | length == 1 and .[0].FromPort == 80 and .[0].ToPort == 80 and .[0].IpProtocol == "tcp"' /tmp/sg.json
aws iam get-role --role-name "$ROLE"
aws iam get-instance-profile --instance-profile-name "$ROLE"
aws s3api head-bucket --bucket "$BUCKET"
aws s3api get-bucket-versioning --bucket "$BUCKET" | jq -e '.Status == "Enabled"'
aws s3api get-bucket-encryption --bucket "$BUCKET" | jq -e '.ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm == "AES256"'
aws s3api get-public-access-block --bucket "$BUCKET" | jq -e '.PublicAccessBlockConfiguration | .BlockPublicAcls and .IgnorePublicAcls and .BlockPublicPolicy and .RestrictPublicBuckets'
curl --fail --retry 30 --retry-all-errors --retry-delay 10 --connect-timeout 5 --max-time 15 "$(read_output application_url)" > /tmp/landing.html
grep -q 'Project 3 deployment successful' /tmp/landing.html
echo "PASS: infrastructure and application validation"
