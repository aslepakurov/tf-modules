terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.50.0"
    }
  }

  backend "s3" {
    bucket         = "test-backend-tf"
    key            = "test-tf/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "test-tf-lock"
  }
}

module "iam-roles" {
  source = "./.."

  iam_role_name = "testRoleForTF"
  policy_files = {
    test_policy = "test_policy.json"
  }
  assume_file = "test_assume.json"
  tags = {
    "issued-by" : "drew"
    "purpose": "test"
  }
}