terraform {
  backend "s3" {
    bucket         = "goit-devops-hw-state-20250708"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-2"
    use_lockfile = true
    encrypt        = true
  }
}