terraform {
  required_providers {
    mongodbatlas = {
      source = "terraform-providers/mongodbatlas"
      version = "= 0.8.0"
    }
  }
}
# Configure the MongoDB Atlas Provider
provider "mongodbatlas" {
  public_key = var.mongodbatlas_public_key
  private_key  = var.mongodbatlas_private_key
}

# Cluster
# DB User
# IP Whitelist