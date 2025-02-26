# Production environment configuration
# Direct reference to root terragrunt.hcl
include {
  path = "${get_parent_terragrunt_dir()}/terragrunt.hcl"
}

locals {
  environment = "production"
  
  # EKS cluster configuration
  cluster_name    = "norel-eks-cluster"
  cluster_version = "1.29"
  
  # VPC configuration
  vpc_id     = "vpc-0a1bbef550af64d2f"
  vpc_cidr   = "10.29.104.0/22"
  subnet_ids = ["subnet-02d62dcb60871aeab", "subnet-04bb48e5b37a0affe"]
  
  # Node group configuration
  node_group_name = "norel-node-group"
  instance_types  = ["t3.medium"]
  
  # Common tags
  common_tags = {
    Environment = local.environment
    Terraform   = "true"
    Project     = local.cluster_name
  }
} 