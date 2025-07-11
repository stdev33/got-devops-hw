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
docker buildx build --platform linux/amd64 -t lesson-5-ecr:latest . --load
docker tag lesson-5-ecr:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/lesson-5-ecr:latest
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/lesson-5-ecr:latest
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
