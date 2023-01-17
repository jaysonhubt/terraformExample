resource "aws_ecr_repository" "ecr_repo" {
  name                 = "${var.app_environment}-${var.ecr_repo}"
  image_tag_mutability = "MUTABLE"
}