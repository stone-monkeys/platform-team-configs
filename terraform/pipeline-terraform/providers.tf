terraform {
  backend "s3" {
    bucket = "fe-cluster-tf-state"
    region = "us-west-2"
    # Defined by config.yml
    #key            = "fe-platform-demo/port/terraform.tfstate"
    dynamodb_table = "cera-tf-lock"
  }
  required_providers {
    circleci = {
      # currently depends on config.yml creation of ~/.terraform.d/plugins/circleci.com/circleci/circleci/0.0.1/linux_amd64 directory containing binary
      source = "circleci.com/circleci/circleci"
    }
  }
}

provider "circleci" {
  host = "https://circleci.com/api/v2/"
  #key  = "*****"
  # Using envvar CIRCLE_TOKEN
}