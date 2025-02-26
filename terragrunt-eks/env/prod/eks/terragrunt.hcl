include {
  path = find_in_parent_folders()
}

inputs = {
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version
  vpc_id          = local.vpc_id
  subnet_ids      = local.subnet_ids
  node_group_name = local.node_group_name
  instance_types  = local.instance_types
  tags            = local.common_tags
}

locals {
  # Import variables from parent
  env_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
  
  # Use the common variables from the environment configuration
  cluster_name    = local.env_vars.locals.cluster_name
  cluster_version = local.env_vars.locals.cluster_version
  vpc_id          = local.env_vars.locals.vpc_id
  subnet_ids      = local.env_vars.locals.subnet_ids
  node_group_name = local.env_vars.locals.node_group_name
  instance_types  = local.env_vars.locals.instance_types
  common_tags     = local.env_vars.locals.common_tags
} 