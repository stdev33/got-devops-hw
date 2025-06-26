# got-devops-hw

## Homework 5 - IaC (Terraform)

DevOps CI/CD course at GoIT Neoversity

This project demonstrates Infrastructure as Code (IaC) using Terraform to provision and manage AWS infrastructure. It includes:

- Remote backend with state storage in S3 and locking via DynamoDB
- VPC setup with public and private subnets, internet and NAT gateways
- ECR repository for Docker image storage

---

## 📁 Project Structure

```
lesson-5/
├── backend.tf          # Remote backend configuration (S3 + DynamoDB)
├── main.tf             # Main file that connects all Terraform modules
├── outputs.tf          # Combined outputs from modules
├── README.md           # Project documentation
└── modules/
    ├── s3-backend/     # S3 + DynamoDB backend module
    ├── vpc/            # VPC and networking module
    └── ecr/            # ECR repository module
```

---

## 🔧 Usage

Initialize, preview, apply and destroy infrastructure:

```bash
terraform init       # Initialize Terraform and remote backend
terraform plan       # Preview changes to be applied
terraform apply      # Apply infrastructure changes
terraform destroy    # Remove all created resources
```

---

## 📦 Module Overview

### `s3-backend`

Sets up an S3 bucket with versioning and server-side encryption for storing Terraform state files, along with a DynamoDB table for state locking.

**Resources:**

- S3 bucket (with versioning and encryption)
- DynamoDB table (for locking)

### `vpc`

Creates a new VPC with:

- 3 public subnets
- 3 private subnets
- Internet Gateway for public subnets
- NAT Gateway for private subnets
- Routing tables for proper traffic flow

**Parameters:**

- `vpc_cidr_block`
- `public_subnets`
- `private_subnets`
- `availability_zones`

### `ecr`

Creates an Elastic Container Registry (ECR) repository with automated image scanning on push.

**Features:**

- Automatic scanning
- Push/pull access policy

---

## ⚠️ Important

After testing your infrastructure, run:

```bash
terraform destroy
```

to avoid unexpected AWS charges. Destroying infrastructure will also remove the S3 backend and DynamoDB table used for state storage.
