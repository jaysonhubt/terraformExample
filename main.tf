provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-jammy-*"
    ]
  }

  filter {
    name = "virtualization-type"
    values = [
      "hvm"
    ]
  }

  owners = [
    "099720109477"]
}

resource "aws_instance" "terraform_ec2" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  tags = {
    Name = "Terraform Ec2"
  }
}

resource "aws_s3_bucket" "terraform_s3" {
  bucket = "jayson-terraform-s3-bucket"
  tags = {
    Name = "Terraform S3"
  }
}