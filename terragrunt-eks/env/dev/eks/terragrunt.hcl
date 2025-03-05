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
  source = "../../../modules/eks"
}

inputs = {
  cluster_name    = include.env.locals.cluster_name
  cluster_version = include.env.locals.cluster_version
  vpc_id          = include.env.locals.vpc_id
  subnet_ids      = include.env.locals.subnet_ids
  node_group_name = include.env.locals.node_group_name
  instance_types  = include.env.locals.instance_types
  tags            = include.env.locals.common_tags
  
  # Use security group rules from env.hcl
  ingress_rules = include.env.locals.security_group_ingress_rules
  egress_rules  = include.env.locals.security_group_egress_rules
}

# locals {
#   # These variables are inherited from prod.hcl through the include directive
#   cluster_name    = include.locals.cluster_name
#   cluster_version = include.locals.cluster_version
#   vpc_id          = include.locals.vpc_id
#   subnet_ids      = include.locals.subnet_ids
#   node_group_name = include.locals.node_group_name
#   instance_types  = include.locals.instance_types
#   common_tags     = include.locals.common_tags
# } 