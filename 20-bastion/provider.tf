terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.48.0"
    }
  }
  backend "s3" {
    bucket = "daws78s-prudvi"
    key    = "bastion-expense-dev-122"
    region = "us-east-1"
    dynamodb_table = "daws78s-prudvi-locking"
  }
}



provider "aws" {
    region = "us-east-1"
}