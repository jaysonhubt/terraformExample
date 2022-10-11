provider "aws" {
  region = "us-east-1"
}

// ------- VPC -------
locals {
  private  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  zone    = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    "Name" = "vpc"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(local.private)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.private[count.index]
  availability_zone = local.zone[count.index % length(local.zone)]

  tags = {
    "Name" = "private-subnet"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(local.public)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.public[count.index]
  availability_zone = local.zone[count.index % length(local.zone)]

  tags = {
    "Name" = "public-subnet"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "internet gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    "Name" = "route table"
  }
}

resource "aws_route_table_association" "public_association" {
  for_each       = { for k, v in aws_subnet.public_subnet : k => v }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "public" {
  depends_on = [aws_internet_gateway.ig]

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "Public NAT"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.public.id
  }

  tags = {
    "Name" = "private"
  }
}

resource "aws_route_table_association" "public_private" {
  for_each       = { for k, v in aws_subnet.private_subnet : k => v }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table.id
}

// ------- End VPC -------

// ------- EC2 -------

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
    "099720109477"
  ]
}

resource "aws_instance" "terraform_ec2" {
  count = 2
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  tags = {
    Name = "Terraform Ec2"
  }
}

output "ec2" {
  value = {
  // public_ip = [ for v in aws_instance.terraform_ec2 : v.public_ip ]
  for i, v in aws_instance.terraform_ec2 : format("pubic_ip%d", i + 1) => v.public_ip
  }
}
// ------- End EC2 -------

// ------- S3 -------

locals {
  mime_types = {
    html  = "text/html"
  }
  tags = {
    Name = "Terraform S3"
  }
}

resource "aws_s3_bucket" "terraform_s3" {
  bucket = var.s3_bucket_name
  tags = local.tags
}

resource "aws_s3_bucket_acl" "terraform_s3" {
  bucket = aws_s3_bucket.terraform_s3.id
  acl = "public-read"
}

resource "aws_s3_bucket_policy" "terraform_s3" {
  bucket = var.s3_bucket_name
  policy = templatefile("s3_static_policy.json", { bucket = var.s3_bucket_name })
}

resource "aws_s3_bucket_website_configuration" "terraform_s3" {
  bucket = aws_s3_bucket.terraform_s3.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "object" {
  for_each = fileset(path.module, "s3-static/**/*")
  bucket = aws_s3_bucket.terraform_s3.id
  key    = replace(each.value, "s3-static", "")
  source = each.value
  etag         = filemd5(each.value)
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}

// ------- End S3 -------