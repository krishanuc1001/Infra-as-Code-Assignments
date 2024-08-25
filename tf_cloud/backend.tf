terraform {
  backend "remote" {
    organization = "TWKrish"

    workspaces {
      name = "TWKrishWorkspace"
    }
  }
}
