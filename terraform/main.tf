terraform {
  backend "gcs" {
    bucket = "devops-0794-personal-terraform"
    prefix = "/state/storybooks"
  }
}