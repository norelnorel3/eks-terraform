include "env" {
  path = "../prod.hcl"
  expose = true  
}

include "root" {
  path = "../../../root.hcl"
  expose = true  
}

terraform {
  source = "../../../modules/efs"
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  cluster_name   = include.env.locals.cluster_name
  vpc_id         = include.env.locals.vpc_id
  vpc_cidr       = include.env.locals.vpc_cidr
  subnet_ids     = include.env.locals.subnet_ids
  node_role_name = dependency.eks.outputs.node_role_name
  tags           = include.env.locals.common_tags
}

# locals {
#   # Import variables from parent
#   env_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
  
#   # Use the common variables from the environment configuration
#   cluster_name = local.env_vars.locals.cluster_name
#   vpc_id       = local.env_vars.locals.vpc_id
#   vpc_cidr     = local.env_vars.locals.vpc_cidr
#   subnet_ids   = local.env_vars.locals.subnet_ids
#   common_tags  = local.env_vars.locals.common_tags
# } 