provider "aws" {
  region = var.region
}

provider "docker" {
    registry_auth {
        address = local.aws_ecr_url
    }
  
}