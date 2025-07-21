# got-devops-hw

## Homework 7 — Kubernetes and ECR Deployment

DevOps CI/CD course at GoIT Neoversity

This project demonstrates deploying a Django application in AWS using Infrastructure as Code (IaC) with Terraform, Docker, and Kubernetes (EKS), along with Helm for Kubernetes resource management.

---

## 📁 Project Structure

```
lesson-5/
├── backend.tf                   # Remote backend configuration (S3 + DynamoDB)
├── main.tf                      # Terraform main file
├── outputs.tf                   # Output values for infrastructure
├── iam-ebs-csi.tf               # IAM role for EBS CSI driver
├── .terraform.lock.hcl
├── modules/                     # Custom Terraform modules
│   ├── s3-backend/              # S3 + DynamoDB for state storage
│   ├── vpc/                     # VPC and networking configuration
│   └── ecr/                     # ECR repository module
├── charts/
│   └── django-app/              # Helm chart for Django app
│       ├── templates/
│       │   ├── configmap.yaml
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   └── hpa.yaml
│       ├── values.yaml          # Values including environment variables
│       └── Chart.yaml
```

---

## ⚙️ Setup Workflow

### 1. Provision Infrastructure with Terraform

```bash
terraform init         # Initialize Terraform backend
terraform plan         # Preview infrastructure changes
terraform apply        # Create infrastructure on AWS (VPC, ECR, etc.)
```

### 2. Build and Push Docker Image to ECR

```bash
docker buildx build --platform linux/amd64 -t final-project-ecr:latest . --load
docker tag final-project-ecr:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/final-project-ecr:latest
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/final-project-ecr:latest
```

Replace `<aws_account_id>` and `<region>` with your actual values (e.g., `121905340549`, `us-west-2`).

### 3. Deploy Django App to EKS using Helm

```bash
helm upgrade django-app . --namespace default --reset-values
kubectl rollout restart deployment django-app-deployment
kubectl get pods -l app=django-app
```

## 🚀 Apply Terraform

Provision all infrastructure and Helm releases (Jenkins and Argo CD) in one go:

```bash
cd lesson-5
terraform init
terraform plan
terraform apply
```

## 🧪 Verify Jenkins Pipeline

1. Open your Jenkins UI, e.g. `http://<JENKINS_HOST>/`.
2. Select the pipeline job (e.g. `lesson-5-pipeline`) in the list.
3. Click **Build Now** or push a change to the Git repo to trigger an automatic build.
4. Inspect the console output to ensure that stages **Build & Push Docker Image** and **Update Helm Chart and Push** complete successfully.

## 🔄 View in Argo CD

1. Open the Argo CD UI at the LoadBalancer address shown by:
   ```bash
   kubectl -n argocd get svc argo-cd-argocd-server \
     -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"
   ```
   then navigate to `https://<hostname>`.
2. Log in with:
   - Username: `admin`
   - Password:
     ```bash
     kubectl -n argocd get secret argocd-initial-admin-secret \
       -o jsonpath="{.data.password}" | base64 --decode && echo
     ```
3. In **Applications**, click **REFRESH APPS** to see your `django-app` entry.
4. If syncPolicy is automated, any new Helm chart commit (from Jenkins) will be deployed automatically; otherwise click **SYNC**.

---

## 🧠 Notes

- Helm chart includes:

  - Deployment with environment variables from `ConfigMap`
  - Service (type LoadBalancer)
  - Horizontal Pod Autoscaler (HPA)

- `values.yaml` holds all configurable values such as:
  - `DJANGO_ALLOWED_HOSTS`
  - `DATABASE_URL`
  - Image repository and tag

---

## 🔥 Teardown

To avoid AWS charges, destroy all resources when no longer needed:

```bash
terraform destroy
```

> This will remove the EKS cluster, VPC, ECR, and state backend (S3 + DynamoDB).

## 🗄️ RDS Module

This project includes a reusable Terraform module for provisioning either a standard RDS instance or an Aurora cluster, based on the `use_aurora` flag.

### Example Usage

```hcl
module "rds" {
  source                    = "./modules/rds"
  name                      = "myapp-db"
  use_aurora                = false         # set true to use Aurora cluster

  # Aurora settings (only if use_aurora = true)
  engine_cluster            = "aurora-postgresql"
  engine_version_cluster    = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"
  aurora_replica_count      = 2

  # Standard RDS settings (only if use_aurora = false)
  engine                    = "postgres"
  engine_version            = "17.2"
  parameter_group_family_rds = "postgres17"
  allocated_storage         = 5

  instance_class            = "db.t3.medium"
  db_name                   = "myapp"
  username                  = "postgres"
  password                  = "admin123AWS23"
  vpc_id                    = module.vpc.vpc_id
  subnet_private_ids        = module.vpc.private_subnet_ids
  subnet_public_ids         = module.vpc.public_subnet_ids
  publicly_accessible       = true
  multi_az                  = true
  backup_retention_period   = 7

  # Optional database parameters (applied via Parameter Group)
  parameters = {
    max_connections             = "200"
    log_min_duration_statement  = "500"
  }

  # Tags applied to all resources
  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

### Module Variables

- `name` (string)  
  Base name for the database resources (used in identifiers and group names).

- `use_aurora` (bool, default=false)  
  When `true`, creates an Aurora cluster; when `false`, creates a single RDS instance.

- **Aurora-specific**

  - `engine_cluster` (string, e.g. `aurora-postgresql`)
  - `engine_version_cluster` (string, Aurora engine version)
  - `parameter_group_family_aurora` (string, Parameter Group family name for Aurora)
  - `aurora_replica_count` (number, default=1) Number of reader instances.

- **RDS-specific**

  - `engine` (string, e.g. `postgres` or `mysql`)
  - `engine_version` (string, RDS engine version)
  - `parameter_group_family_rds` (string, Parameter Group family name for RDS)
  - `allocated_storage` (number, GB of storage).

- **Common settings**
  - `instance_class` (string, compute instance size)
  - `db_name` (string, initial database name)
  - `username` (string, master username)
  - `password` (string, master password)
  - `vpc_id` (string, VPC ID for SG and Subnet Group)
  - `subnet_private_ids` (list(string), private subnet IDs)
  - `subnet_public_ids` (list(string), public subnet IDs)
  - `publicly_accessible` (bool, default=false)
  - `multi_az` (bool, default=false)
  - `backup_retention_period` (number, days for backups)
  - `parameters` (map(string), custom DB parameters)
  - `tags` (map(string), tags to apply to all created resources)

### Changing Database Type or Configuration

- To switch between **RDS** and **Aurora**, toggle `use_aurora` in your module invocation.
- Modify `engine`, `engine_version`, and `parameter_group_family_*` to select MySQL vs PostgreSQL or specific versions.
- Change `instance_class` to adjust compute capacity.
- Adjust `allocated_storage`, `multi_az`, and `backup_retention_period` to suit performance and durability needs.
