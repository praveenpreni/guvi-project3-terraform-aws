# Verification - 13 October 2026

- Terraform 1.14.7 recursive format check passed.
- Root and bootstrap Terraform validate passed.
- AWS provider 6.68.0 initialized using official signed checksums.
- Provider lock includes Windows amd64 and Linux amd64 checksums.
- Workflow YAML parsed successfully.
- GitHub Actions run #5 (38372265918), deployed commit 97256cf, succeeded after push.
- Plan job: format, environment protection check, OIDC, backend init, validate, saved plan and artifact upload succeeded.
- Apply job: production approval, OIDC, backend init, saved artifact download/checksum verification, apply, outputs and infrastructure validation succeeded.
- Runner validation checks EC2 status/IP/IMDSv2, VPC/subnets, EIP, inbound HTTP rule, IAM profile, S3 versioning/encryption/public access and HTTP landing page.
- AWS Console evidence confirms the deployed infrastructure; browser shows the custom application through the Elastic IP.
- Native S3 lockfile is enabled. An unlocked backend normally retains terraform.tfstate without a lock object.
- Submission is pending owner action.

https://github.com/praveenpreni/guvi-project3-terraform-aws/actions/runs/38372265918
