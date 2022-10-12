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