vpc_cidr_block = "10.0.0.0/16"
private_subnet = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnet = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
availability_zone = ["us-east-1a", "us-east-1b", "us-east-1c"]

instance_type = "t3.small"

s3_bucket_name = "jayson-terraform-s3-bucket-prod"