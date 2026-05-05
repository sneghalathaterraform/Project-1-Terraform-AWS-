# provider.tf
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
   cloud {
    organization = "Project-1-Terraform-Resources"   # ← add this
    workspaces {
      tags = [ "project-1" ]                            # ← tag based
    }
  }       # ← empty, gets filled by -backend-config at init
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}