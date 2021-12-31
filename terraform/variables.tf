### GENERAL
variable "app_name" {
    type = string
    default = ""
}

### ATLAS
variable "mongodbatlas_public_key" {
  type = string
}
variable "mongodbatlas_private_key" {
  type = string
}

### GCP
variable "gcp_machine_type" {
  type = string
}
