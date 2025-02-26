# Root terragrunt.hcl file
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

# Generate provider configurations
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"  # Required for ECR Public
}
EOF
}

# Generate versions.tf
generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
  }
}
EOF
}

# Generate data_sources.tf
# generate "data_sources" {
#   path      = "data_sources.tf"
#   if_exists = "overwrite_terragrunt"
#   contents  = <<EOF
# data "aws_eks_cluster" "cluster" {
#   name = "${local.cluster_name}"
# }
# EOF
# }

# Define common locals
locals {
  aws_region   = "eu-west-1"
  cluster_name = "norel-eks-cluster"  # Default value, can be overridden in environment config
} 