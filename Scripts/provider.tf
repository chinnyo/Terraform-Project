terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider, and select a region closest to you, in my case its as stated below
provider "aws" {
  region = "eu-west-1"
}