terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }

  backend "s3" {
    bucket         = "gitops-engine-tfstate"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "gitops-engine-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}
