resource "aws_ecr_repository" "keycloak" {
  name = "keycloak"

}
resource "docker_registry_image" "backend" {
  name = "${aws_ecr_repository.keycloak.repository_url}:latest"

  build {
    context    = "../application"
    dockerfile = "backend.Dockerfile"
  }
}
