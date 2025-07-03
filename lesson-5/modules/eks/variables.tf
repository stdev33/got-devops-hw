variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "IAM role ARN for the EKS cluster control plane"
  type        = string
}

variable "node_role_name" {
  description = "IAM role name for EKS Node Group"
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN for the EKS worker nodes"
  type        = string
}

variable "region" {
  description = "AWS region where EKS will be deployed"
  type        = string
  default     = "us-west-2"
}

variable "cluster_role_name" {
  description = "The name of the IAM role for the EKS cluster"
  type        = string
}

variable "node_instance_profile_name" {
  type        = string
  description = "IAM Instance Profile for worker nodes"
}