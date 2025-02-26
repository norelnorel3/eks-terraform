include {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = "../eks"
}

inputs = {
  cluster_name   = local.cluster_name
  vpc_id         = local.vpc_id
  vpc_cidr       = local.vpc_cidr
  subnet_ids     = local.subnet_ids
  node_role_name = dependency.eks.outputs.node_role_name
  tags           = local.common_tags
}

locals {
  # Import variables from parent
  env_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
  
  # Use the common variables from the environment configuration
  cluster_name = local.env_vars.locals.cluster_name
  vpc_id       = local.env_vars.locals.vpc_id
  vpc_cidr     = local.env_vars.locals.vpc_cidr
  subnet_ids   = local.env_vars.locals.subnet_ids
  common_tags  = local.env_vars.locals.common_tags
} 