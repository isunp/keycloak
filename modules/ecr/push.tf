resource "docker_image" "keycloak_app" {
  name  = "keycloak-app"
  build = "./ecr/app/src/dockerfile"
}

resource "null_resource" "docker_push" {
  depends_on = [null_resource.docker_build]

  provisioner "local-exec" {
    command = "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin '${aws_ecr_repository.outputs.repository_url}'"
  }

  provisioner "local-exec" {
    command = "docker tag '${var.image_name}':latest '${aws_ecr_repository.outputs.repository_url}'/'${var.image_name}':latest"
  }

  provisioner "local-exec" {
    command = "docker push '${aws_ecr_repository.outputs.repository_url}'/'${var.image_name}':latest"
  }
}

resource "null_resource" "docker_build" {
  provisioner "local-exec" {
    command = "docker build -t '${var.image_name}':latest ."
  }
}
