include "env" {
  path = "../env.hcl"
  expose = true  
}

include "backend" {
  path = "../../../backend.hcl"
  expose = true  
}

include "providers" {
  path = "../../../providers.hcl"
  expose = true  
}

terraform {
  source = "../../../modules/efs"
}

dependency "eks" {
  config_path = "../eks"
  
  mock_outputs = {
    node_role_name = "mock-node-role"
    cluster_security_group_id = "sg-12345"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  cluster_name             = include.env.locals.cluster_name
  vpc_id                   = include.env.locals.vpc_id
  vpc_cidr                 = include.env.locals.vpc_cidr
  subnet_ids               = include.env.locals.subnet_ids
  node_role_name           = dependency.eks.outputs.node_role_name
  cluster_security_group_id = dependency.eks.outputs.cluster_security_group_id
  tags                     = include.env.locals.common_tags
}

##
##