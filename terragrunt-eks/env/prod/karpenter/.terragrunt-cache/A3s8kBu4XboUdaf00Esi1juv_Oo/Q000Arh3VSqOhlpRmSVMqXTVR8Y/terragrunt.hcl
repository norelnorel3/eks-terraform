include "env" {
  path = "../prod.hcl"
  expose = true  
}

include "root" {
  path = "../../../root.hcl"
  expose = true  
}

dependency "efs" {
  config_path = "../efs"
}

dependency "eks" {
  config_path = "../eks"
}

terraform {
  source = "../../../modules/karpenter"
}

inputs = {
  cluster_name             = include.env.locals.cluster_name
  cluster_endpoint         = dependency.eks.outputs.cluster_endpoint
  oidc_provider_url        = dependency.eks.outputs.oidc_provider_url
  subnet_ids               = include.env.locals.subnet_ids
  cluster_security_group_id = dependency.eks.outputs.cluster_security_group_id
  tags                     = include.env.locals.common_tags
}

# locals {
#   # Import variables from parent
#   env_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
  
#   # Use the common variables from the environment configuration
#   cluster_name = local.env_vars.locals.cluster_name
#   subnet_ids   = local.env_vars.locals.subnet_ids
#   common_tags  = local.env_vars.locals.common_tags
# } 




generate "kubernetes_providers" {
  path      = "kubernetes_providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
data "aws_eks_cluster" "cluster" {
  name = "${include.env.locals.cluster_name}"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.cluster.name
    ]
  }
}

provider "kubectl" {
  apply_retry_count      = 15
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        data.aws_eks_cluster.cluster.name
      ]
    }
  }
}
EOF
}