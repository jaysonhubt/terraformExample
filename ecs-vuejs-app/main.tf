provider "aws" {
  region = "us-east-1"
}

module "ecr" {
  source = "./ecr"

  app_environment = var.app_environment
  ecr_repo = var.ecr_repo
}

module "ecs" {
  source = "./ecs"

  app_environment = var.app_environment
  ecr_repo = var.ecr_repo
  ecs_cluster = var.ecs_cluster
}