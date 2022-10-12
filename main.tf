provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./vpc"

  vpc_cidr_block = var.vpc_cidr_block
  private_subnet = var.private_subnet
  public_subnet = var.public_subnet
  availability_zone = var.availability_zone
}

module "ec2" {
  source = "./ec2"

  instance_type = var.instance_type
}

module "s3" {
  source = "./s3"

  s3_bucket_name = var.s3_bucket_name
}