include {
  path = find_in_parent_folders()
}

dependency "eks" {
  config_path = "../eks"
}

dependency "efs" {
  config_path = "../efs"
}

inputs = {
  cluster_name     = local.cluster_name
  oidc_provider_url = dependency.eks.outputs.oidc_provider_url
  efs_id           = dependency.efs.outputs.id
  tags             = local.common_tags
}

locals {
  # Import variables from parent
  env_vars = read_terragrunt_config(find_in_parent_folders("terragrunt.hcl"))
  
  # Use the common variables from the environment configuration
  cluster_name = local.env_vars.locals.cluster_name
  common_tags  = local.env_vars.locals.common_tags
} 