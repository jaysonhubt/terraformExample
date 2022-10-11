https://www.terraform.io/

#Directory structrue
- main.tf: Main terraform file
- variable.tf: Define variables will be used in main.tf
- terraform.tfvars: Default variable values
- production.tfvars: Run with other variable file with option `-var-file`. Example `terraform apply -var-file="production.tfvars"`
- terraform.lock.hcl: similar to composer.lock, package-lock.json

#Basic command:

- terraform init: Init terraform provider will be used
- terraform plan: preview the changes that Terraform plans to make to your infrastructure
- terraform apply: Executes the actions proposed in a Terraform plan
- terraform destroy: Destroy all resources

- Lifecycle

![asd](https://raw.githubusercontent.com/jaysonhubt/terraformExample/master/assets/life-cycle.webp)
