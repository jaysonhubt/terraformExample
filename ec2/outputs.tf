output "ec2" {
  value = {
  // public_ip = [ for v in aws_instance.terraform_ec2 : v.public_ip ]
  for i, v in aws_instance.terraform_ec2 : format("pubic_ip%d", i + 1) => v.public_ip
  }
}