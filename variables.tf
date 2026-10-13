variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "environment" {
  type    = string
  default = "dev"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "Use lowercase letters, numbers and hyphens."
  }
}
variable "vpc_cidr" {
  type    = string
  default = "10.30.0.0/16"
}
variable "subnet_cidrs" {
  type    = list(string)
  default = ["10.30.1.0/24", "10.30.2.0/24"]
  validation {
    condition     = length(var.subnet_cidrs) == 2
    error_message = "Provide exactly two subnet CIDRs."
  }
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "ami_id" {
  type        = string
  default     = null
  description = "Optional x86_64 Amazon Linux 2023 AMI override."
}
