terraform {
  required_providers {
    aws = {
      version = ">= 3.56.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}
