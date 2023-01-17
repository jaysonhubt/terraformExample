variable "app_environment" {
  type = string
  description = "App environment"
}

variable "ecr_repo" {
  type = string
  description = "ECR repository name"
}

variable "ecs_cluster" {
  type = string
  description = "ECS Cluster name"
}