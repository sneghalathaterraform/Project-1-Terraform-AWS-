# HCP Terraform Project - AWS Infrastructure as Code

This project follows the **HCP Terraform (Terraform Cloud)** best practices and structure.

## 📁 Project Structure

```
terraform/
├── modules/                    # Reusable infrastructure modules
│   ├── vpc/                   # VPC configuration
│   ├── iam/                   # IAM roles and policies
│   ├── ec2/                   # EC2 instances
│   └── s3/                    # S3 buckets
│
└── environments/              # Root modules for each environment
    ├── dev/                   # Development workspace
    ├── prod/                  # Production workspace
    └── qa/                    # QA/Staging workspace
```

## 🚀 Quick Start

### Prerequisites
- Terraform >= 1.5.0
- AWS CLI configured with credentials
- HCP Terraform account and organization

### Initialize and Deploy

**For Dev Environment:**
```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

**For Prod Environment:**
```bash
cd terraform/environments/prod
terraform init
terraform plan
terraform apply
```

**For QA Environment:**
```bash
cd terraform/environments/qa
terraform init
terraform plan
terraform apply
```

## 🏗️ HCP Terraform Configuration

Each environment is configured to use HCP Terraform with the following organization:
- **Organization**: `Project-1-Terraform-Resources`
- **Workspaces**:
  - `Project-dev-AWS`
  - `Project-PROD-AWS`
  - `Project-QA-AWS`

Remote state is automatically managed by HCP Terraform.

## 📝 File Structure Details

### Provider Configuration (`provider.tf`)
- AWS provider configuration
- Cloud backend for HCP Terraform
- Default tags for all resources

### Module Definitions (`main.tf`)
- VPC module with network configuration
- IAM module for roles and policies
- EC2 module for compute resources
- S3 module for storage

### Variables (`variables.tf`)
- Environment-specific variable declarations

### Outputs (`outputs.tf`)
- Exported values for each environment

### Terraform Variables (`terraform.tfvars`)
- Environment-specific values

## 🔄 Workflow

1. **Make changes** to modules or root configurations
2. **Commit to Git** - Automatically triggers VCS-driven workflow in HCP Terraform
3. **Review Plan** - In HCP Terraform console
4. **Apply Changes** - Approval required for production

## 📊 Modules Overview

### VPC Module
- Creates VPC with configurable CIDR block
- Creates public subnet
- Manages availability zones

### IAM Module
- EC2 instance role and profile
- S3 access policies
- Service-linked policies

### EC2 Module
- Amazon Linux 2 instances
- Auto-selection of latest AMI
- IAM instance profile attachment

### S3 Module
- S3 bucket creation
- Environment-based naming
- Default tags

## 🔐 Security Best Practices

- Secrets managed in HCP Terraform variables
- All resources tagged for cost allocation
- IAM policies follow least privilege principle
- State management handled by HCP Terraform

## 📚 Additional Resources

- [HCP Terraform Documentation](https://www.terraform.io/cloud-docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/best-practices.html)
