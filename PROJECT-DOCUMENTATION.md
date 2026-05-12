# Project-1: AWS Infrastructure with Terraform — Multi-Environment Setup

## Project Overview

This project provisions AWS infrastructure across three isolated environments
(dev, qa, prod) using Terraform modules and the HCP Terraform VCS-driven
workflow. All infrastructure is defined as code, stored in GitHub, and applied
remotely through HCP Terraform workspaces — no local `terraform apply` is used.

---

## Tools & Technologies

| Tool | Purpose |
|---|---|
| Terraform (>= 1.5.0) | Infrastructure as Code |
| AWS Provider (~> 5.0) | Cloud resource provisioning |
| HCP Terraform Cloud | Remote state, remote execution, workspace management |
| GitHub | Version control, VCS trigger for HCP Terraform |
| AWS (us-east-1) | Target cloud provider |

---

## Architecture: HCP Terraform VCS-Driven Workflow

```
Developer
   │
   │  git push (main branch)
   ▼
GitHub Repository
   │
   │  Webhook trigger
   ▼
HCP Terraform Cloud (Org: Project-1-Terraform-Resources)
   │
   ├── Workspace: Project-dev-AWS   ──► terraform/environments/dev
   ├── Workspace: Project-qa-AWS    ──► terraform/environments/qa
   └── Workspace: Project-PROD-AWS  ──► terraform/environments/prod
         │
         │  Remote Plan → Manual Confirm & Apply
         ▼
      AWS Cloud (us-east-1)
         ├── VPC + Subnets + Routing
         ├── EC2 Instance
         ├── IAM Role + Policy
         └── S3 Bucket
```

**Key principle:** The VCS (GitHub) is the single source of truth.
Every infrastructure change must go through a git push — no local applies allowed.

---

## Project Folder Structure

```
Project-1/
└── terraform/
    ├── modules/                    # Reusable modules (shared across envs)
    │   ├── vpc/
    │   │   ├── main.tf             # VPC, subnets, IGW, NAT GW, route tables
    │   │   ├── variables.tf
    │   │   └── outputs.tf
    │   ├── ec2/
    │   │   ├── main.tf             # EC2 instance, AMI data source
    │   │   ├── variables.tf
    │   │   └── outputs.tf
    │   ├── iam/
    │   │   ├── main.tf             # IAM role, instance profile, S3 policy
    │   │   ├── variables.tf
    │   │   └── outputs.tf
    │   └── s3/
    │       ├── main.tf             # S3 bucket
    │       ├── variables.tf
    │       └── outputs.tf
    │
    └── environments/               # Per-environment Terraform root configs
        ├── dev/
        │   ├── provider.tf         # cloud{} block → HCP workspace: Project-dev-AWS
        │   ├── main.tf             # Calls all 4 modules
        │   ├── variables.tf
        │   ├── outputs.tf
        │   └── terraform.tfvars   # Dev-specific variable values
        ├── qa/
        │   ├── provider.tf         # cloud{} block → HCP workspace: Project-qa-AWS
        │   ├── main.tf
        │   ├── variables.tf
        │   ├── outputs.tf
        │   └── terraform.tfvars
        └── prod/
            ├── provider.tf         # cloud{} block → HCP workspace: Project-PROD-AWS
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            └── terraform.tfvars
```

---

## AWS Infrastructure Provisioned (per environment)

### VPC Module (`modules/vpc`)

| Resource | Name | Notes |
|---|---|---|
| `aws_vpc` | project-{env}-vpc | CIDR from var.vpc_cidr_block |
| `aws_internet_gateway` | project-{env}-igw | Enables public subnet internet access |
| `aws_subnet` (public) | project-{env}-public-subnet | AZ: us-east-1a, map_public_ip_on_launch = true |
| `aws_subnet` (private) | project-{env}-private-subnet | No direct internet access |
| `aws_route_table` (public) | project-{env}-public-rt | Routes 0.0.0.0/0 → IGW |
| `aws_route_table_association` (public) | — | Links public subnet to public RT |
| `aws_eip` | project-{env}-nat-eip | Only in prod |
| `aws_nat_gateway` | project-{env}-nat-gw | Only in prod (enable_nat_gateway = true) |
| `aws_route_table` (private) | project-{env}-private-rt | Routes 0.0.0.0/0 → NAT GW (prod only) |
| `aws_route_table_association` (private) | — | Links private subnet to private RT (prod only) |

### EC2 Module (`modules/ec2`)

| Resource | Name | Notes |
|---|---|---|
| `aws_instance` | project-{env}-ec2 | Amazon Linux 2 (latest AMI), placed in public subnet |
| `data.aws_ami` | — | Fetches latest Amazon Linux 2 AMI automatically |

### IAM Module (`modules/iam`)

| Resource | Name | Notes |
|---|---|---|
| `aws_iam_role` | project-{env}-ec2-role | Trust policy: ec2.amazonaws.com |
| `aws_iam_instance_profile` | project-{env}-ec2-profile | Attached to EC2 instance |
| `aws_iam_policy` | project-{env}-s3-full-access | Grants s3:* on the project bucket |
| `aws_iam_role_policy_attachment` | — | Attaches S3 policy to EC2 role |

### S3 Module (`modules/s3`)

| Resource | Name |
|---|---|
| `aws_s3_bucket` | var.bucket_name (project-{env}-bucket) |

---

## Environment Comparison

| Setting | dev | qa | prod |
|---|---|---|---|
| VPC CIDR | 10.0.0.0/16 | 10.1.0.0/16 | 10.2.0.0/16 |
| EC2 Instance Type | t3.micro | t3.small | t3.small |
| NAT Gateway | No | No | Yes |
| Bucket Name | my-project-dev-snegha-123 | my-project-qa-snegha-123 | my-project-prod-snegha-123 |
| HCP Workspace | Project-dev-AWS | Project-qa-AWS | Project-PROD-AWS |
| Working Directory | terraform/environments/dev | terraform/environments/qa | terraform/environments/prod |

---

## HCP Terraform Workspace Configuration

For each workspace, configure the following in **Settings → Version Control**:

| Setting | Value |
|---|---|
| VCS Branch | `main` |
| Terraform Working Directory | `terraform/environments/{env}` |
| Auto Apply | Off (manual confirm required) |

### Workspace Variables (set in HCP Terraform UI → Variables tab)

These are set as **Terraform variables** in each workspace:

| Variable | dev | qa | prod |
|---|---|---|---|
| `environment` | dev | qa | prod |
| `aws_region` | us-east-1 | us-east-1 | us-east-1 |
| `project` | my-project | my-project | my-project |
| `vpc_cidr_block` | 10.0.0.0/16 | 10.1.0.0/16 | 10.2.0.0/16 |
| `instance_type` | t3.micro | t3.small | t3.small |
| `bucket_name` | my-project-dev-snegha-123 | my-project-qa-snegha-123 | my-project-prod-snegha-123 |

> Note: HCP Terraform does not automatically load `terraform.tfvars` from VCS.
> Variables must be set in the workspace UI or via the Terraform Cloud API.

---

## Step-by-Step Implementation Process

### Step 1 — Create Terraform Module Structure

Organised the project into reusable modules and per-environment roots:
- `modules/vpc` — networking
- `modules/ec2` — compute
- `modules/iam` — identity and access
- `modules/s3` — storage
- `environments/dev`, `environments/qa`, `environments/prod` — each calls all 4 modules

### Step 2 — Configure HCP Terraform Cloud

1. Created organisation: `Project-1-Terraform-Resources`
2. Created three workspaces:
   - `Project-dev-AWS`
   - `Project-qa-AWS`
   - `Project-PROD-AWS`
3. Connected each workspace to the GitHub repository (VCS-driven workflow)

### Step 3 — Add `cloud {}` Block to Each Environment

Each environment's `provider.tf` contains:

```hcl
terraform {
  cloud {
    organization = "Project-1-Terraform-Resources"
    workspaces {
      name = "Project-dev-AWS"   # changes per environment
    }
  }
}
```

This links local code to the correct HCP workspace for remote state and execution.

### Step 4 — Fix HCP Workspace Working Directory

**Problem:** HCP Terraform was pointing to the wrong directory.

**Fix:** In each workspace → Settings → Version Control:
- Set **Terraform Working Directory** to `terraform/environments/{env}`
- Set **VCS Branch** to `main`

Without this, HCP Terraform could not find any `.tf` files and returned:
`Error: No Terraform configuration files found in working directory`

### Step 5 — Set Workspace Variables in HCP Terraform UI

**Problem:** HCP Terraform does not load `terraform.tfvars` automatically from VCS.

**Fix:** Manually entered all required variables in each workspace under the
**Variables** tab as Terraform variables.

### Step 6 — Add Private Subnet and NAT Gateway (Cost-Optimized)

Enhanced the VPC module to support private subnets and a conditional NAT Gateway:

**Added to `modules/vpc/main.tf`:**
- Internet Gateway + public route table (also fixed public subnet routing)
- Private subnet
- Elastic IP + NAT Gateway (conditional: `count = var.enable_nat_gateway ? 1 : 0`)
- Private route table routing 0.0.0.0/0 → NAT Gateway (conditional)

**Added to `modules/vpc/variables.tf`:**
```hcl
variable "enable_nat_gateway" {
  type    = bool
  default = false
}
```

**Per-environment control in each `environments/{env}/main.tf`:**
```hcl
module "vpc" {
  source             = "../../modules/vpc"
  enable_nat_gateway = false   # true only in prod
}
```

### Step 7 — Allow tfvars Files in Git

**Problem:** `.gitignore` was excluding all `*.tfvars` files.

**Fix:** Added a negation rule to allow environment tfvars:
```
*.tfvars
!terraform/environments/**/*.tfvars
```

### Step 8 — Push Changes and Trigger HCP Terraform Run

```bash
git add .
git commit -m "your message"
git push origin main
```

HCP Terraform detects the push via GitHub webhook, runs an automatic **Plan**,
then waits for manual **Confirm & Apply** in the UI.

---

## Workflow: Every Infrastructure Change

```
1. Edit .tf files locally
       │
2. git add + git commit + git push origin main
       │
3. HCP Terraform detects push via webhook
       │
4. Automatic Plan runs in HCP Terraform UI
       │
5. Review plan output (+add / ~change / -destroy)
       │
6. Click "Confirm & Apply" in HCP Terraform UI
       │
7. Infrastructure provisioned in AWS
```

---

## Issues Encountered and Resolutions

| # | Error | Root Cause | Fix |
|---|---|---|---|
| 1 | `Apply not allowed for workspaces with a VCS connection` | Tried `terraform apply` locally on a VCS-connected workspace | Use VCS-driven workflow — push to GitHub and confirm in HCP UI |
| 2 | `No Terraform configuration files found in working directory` | Workspace Working Directory was set incorrectly | Set to `terraform/environments/{env}` in workspace settings |
| 3 | `No value for required variable` | HCP Terraform does not auto-load `terraform.tfvars` | Set all variables manually in workspace UI under Variables tab |
| 4 | `No changes. Your infrastructure matches the configuration` | Workspace was watching wrong VCS branch | Changed VCS Branch from `dev` to `main` in workspace settings |
| 5 | `terraform.tfvars` blocked by `.gitignore` | `.gitignore` had `*.tfvars` rule | Added `!terraform/environments/**/*.tfvars` exception |

---

## Key Learnings

1. **VCS-driven workflow** means all changes must go through git — no local applies
2. **HCP Terraform workspace working directory** must exactly match the environment folder path
3. **HCP Terraform does not load tfvars from VCS** — variables must be set in the workspace UI
4. **NAT Gateway costs ~$32/month** — use `enable_nat_gateway = false` in dev/qa to save cost
5. **Remote state** is stored automatically in HCP Terraform per workspace — no manual state management needed
6. **Modules promote reuse** — one module definition serves dev, qa, and prod with different variable values

---

*Project by: Sneghalatha | AWS Cloud Engineer Module-wise Project | Project-1*
