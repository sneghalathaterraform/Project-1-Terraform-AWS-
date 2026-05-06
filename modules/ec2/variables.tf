variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}
variable "iam_instance_profile" {
  description = "IAM instance profile to attach to EC2"
  type        = string
}

variable "project" {
  description = "Project name for tagging"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
}