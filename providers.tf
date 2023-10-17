#Configure AWS Provider
provider "aws" {
  region  = var.region
  profile = var.profile_name
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.20.1"
    }
  }
}