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

variable "enable_nat_gateway" {
  description = "Create a NAT Gateway for private subnet internet access (set true only in prod)"
  type        = bool
  default     = false
}
