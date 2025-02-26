include {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = "../eks"
}

# Add explicit dependencies to ensure proper ordering
dependencies {
  paths = ["../eks"]
}

inputs = {
  cluster_name             = local.cluster_name
  cluster_endpoint         = dependency.eks.outputs.cluster_endpoint
  oidc_provider_url        = dependency.eks.outputs.oidc_provider_url
  subnet_ids               = local.subnet_ids
  cluster_security_group_id = dependency.eks.outputs.cluster_security_group_id
  tags                     = local.common_tags
}

locals {
  # Import variables from parent
  env_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
  
  # Use the common variables from the environment configuration
  cluster_name = local.env_vars.locals.cluster_name
  subnet_ids   = local.env_vars.locals.subnet_ids
  common_tags  = local.env_vars.locals.common_tags
} 