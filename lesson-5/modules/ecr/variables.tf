variable "ecr_name" {
  description = "The name of the ECR repository"
  type        = string
}

variable "scan_on_push" {
  description = "Whether to scan images on push"
  type        = bool
  default     = true
}