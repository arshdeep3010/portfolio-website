terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
  }

  # State is kept locally in infra/terraform.tfstate (git-ignored).
  # Back it up, or move it to an S3 backend later; losing it means
  # Terraform no longer knows about the resources it created.
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "portfolio-website"
      ManagedBy = "terraform"
    }
  }
}
