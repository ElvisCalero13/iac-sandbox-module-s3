terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.13.0"

      configuration_aliases = [
        aws.service-primary,
        aws.service-secondary
      ]
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.2.0"
    }
  }

  required_version = ">= 1.1.3"
}
