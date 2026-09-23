terraform {
  # Keep Terraform and the S3 backend features aligned across local and CI runs.
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  # The remote backend centralizes state and enables safe collaboration.
  backend "s3" {
    bucket       = "ylhan-terraform-state-2026-0001"
    key          = "ansible-lab/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  # The region is configurable through the aws_region input variable.
  region = var.aws_region
}