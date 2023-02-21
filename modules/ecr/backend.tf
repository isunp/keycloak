terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
