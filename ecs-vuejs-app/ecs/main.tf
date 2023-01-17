resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.app_environment}-${var.ecs_cluster}"
  tags = {
    Name        = var.ecs_cluster
    Environment = var.app_environment
  }
}

data "aws_ecr_repository" "ecr_repo" {
  name = "${var.app_environment}-${var.ecr_repo}"
}

data "aws_ecr_image" "ecr_image" {
  repository_name = "${var.app_environment}-${var.ecr_repo}"
  image_tag       = "latest"
}

resource "aws_ecs_task_definition" "service" {
  family = "ecs-vuejs-task"
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([
    {
      name      = "ecs-vuejs-container"
      image     = "${data.aws_ecr_repository.ecr_repo.repository_url}:${data.aws_ecr_image.ecr_image.image_tag}"
      cpu       = 1
      memory    = 256
      memoryReservation = 128
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 80
        }
      ],
      environment = [{
        name = "VUE_APP_ENV_BASE_URL_API",
        value = "https://dummyjson.com"
      }],
    }
  ])

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}