#create docker repository
#build docker image and push to ecr
#setup credentials to push to ecr   

resource "aws_ecr_repository" "keycloak" {
    name = "keycloak"
  
}