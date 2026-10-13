# Project 3 — AWS infrastructure with Terraform and GitHub Actions

## Status
Configuration prepared. Live deployment, AWS screenshots, GitHub run evidence and application URL must be captured before submission. Do not present this source package as a completed deployment.

## Architecture
GitHub push → format → init → validate → saved plan artifact → production environment approval → apply saved plan → outputs → AWS and HTTP validation.

The networking module creates a VPC, two public subnets in separate availability zones, an internet gateway and a public route table with two associations. The compute module creates the web security group, EC2 IAM role/profile, encrypted EC2 instance and Elastic IP. Root configuration creates the private, encrypted, versioned application bucket. User data installs Nginx and a custom landing page.

## Security
Only inbound HTTP port 80 is open. No SSH or embedded credentials. IMDSv2 is required. EC2 can only read objects under this project's application bucket assets/ prefix. HTTP/HTTPS egress supports package installation; VPC DNS uses the Amazon resolver. The demo serves HTTP as requested; TLS would require a certificate and domain.

State and plan files can contain sensitive information. State is private, encrypted and versioned in S3; native S3 locking uses use_lockfile=true (Terraform 1.10+). Plans stay in short-lived Actions artifacts and must not be committed. Commit the generated .terraform.lock.hcl files.

## 1. Bootstrap remote state
Using an authorized AWS session (AWS CloudShell is suitable), install Terraform from the official HashiCorp release and authenticate through the session credentials.
```bash
terraform -chdir=bootstrap init
terraform -chdir=bootstrap plan -var="state_bucket_name=YOUR-UNIQUE-STATE-BUCKET" -out=bootstrap.tfplan
terraform -chdir=bootstrap apply bootstrap.tfplan
```
Keep bootstrap's local state protected and backed up; it is excluded from Git. The bootstrap state bucket has prevent_destroy. Copy backend.hcl.example to backend.hcl and fill the name, then run terraform init -backend-config=backend.hcl. Do not destroy the backend bucket during application cleanup.

## 2. GitHub authentication and approval
Create a GitHub repository with main as its default branch. For GitHub Free, use a public source repository to access required reviewers; never publish credentials, Terraform state or plan files.

Create the production environment, add a required reviewer, restrict deployment to main and disable administrator bypass. For a solo project, allow self-review so you can approve the run.

Use AWS OIDC, with issuer https://token.actions.githubusercontent.com and audience sts.amazonaws.com. Scope the plan role trust subject to repo:OWNER/REPO:ref:refs/heads/main and apply role trust to repo:OWNER/REPO:environment:production. Do not use a wildcard repository trust. A project-specific deploy role needs the EC2, S3 and IAM operations for these resources; restrict IAM PassRole to guvi-project3-dev-ec2 and restrict IAM/S3 writes to project resources. The plan role needs read/list access and remote-state lock-file writes. The apply role also needs the read operations used by scripts/validate.sh. Account-specific role policies must be reviewed and configured before deployment.

Set repository variables:
- AWS_REGION: ap-south-1 (or your selected region)
- TF_STATE_BUCKET: bootstrap bucket name
- AWS_PLAN_ROLE_ARN: scoped plan role ARN
- AWS_APPLY_ROLE_ARN: scoped apply role ARN

Set ENVIRONMENT_READ_TOKEN as an Actions secret: a fine-grained GitHub token for this repository with Environments: read, used only to verify the required-reviewer gate exists. Never put it in a file. Workflow deliberately fails if the gate is missing.

## 3. Deploy
Push the source to main. Open Actions, review plan.txt in the plan artifact and approve the production deployment. Apply consumes that exact saved binary plan; it does not re-plan. Copy the application_url from Terraform Outputs. Validation checks running EC2, EIP, VPC, two subnets, HTTP-only ingress, IAM role/profile, S3 protections and page content.

## Configurable values
variables.tf exposes AWS region, environment, VPC/subnet CIDRs, instance type and AMI. Defaults use Amazon Linux 2023 x86_64 via the AWS public SSM parameter. terraform.tfvars.example shows overrides. For Actions overrides, add TF_VAR_ variables to workflow env.

## Evidence and submission
Follow evidence/CHECKLIST.md. Submit repository URL, Terraform/modules/workflow/.gitignore/README/backend configuration, downloadable plan artifact and working application URL. Capture AWS Console screenshots after successful deployment. Never fabricate run logs or screenshots.

## Cleanup
EC2, EBS, public IPv4 and S3 can incur charges. After grading, review terraform plan -destroy and run terraform destroy using the same backend and AWS session. The application bucket is not force-deleted: remove its objects and versions intentionally if needed. Retain state and evidence securely. Do not remove infrastructure before the reviewer checks the application URL.

## References
- [Terraform S3 backend and native locking](https://developer.hashicorp.com/terraform/language/backend/s3)
- [GitHub deployment review](https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/review-deployments)
