variable "cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "myproject"
}
