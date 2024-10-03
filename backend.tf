terraform {
  backend "s3" {
    bucket = "terraform-ecs-poc"
    key    = "tf"
    region = "us-west-2"
  }
}
