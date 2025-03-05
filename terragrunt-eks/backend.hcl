# Root terragrunt.hcl file
# Created and maintained by Norel Milihov

remote_state {
  backend = "s3"
  config = {
    bucket         = "norel-terragrunt-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    dynamodb_table = "norel-terragrunt-locks"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

