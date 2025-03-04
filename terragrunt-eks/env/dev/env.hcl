# Development environment configuration
# Created and maintained by Norel Milihov

locals {
  environment = "development"
  
  # EKS cluster configuration
  cluster_name    = "dev-eks-cluster"
  cluster_version = "1.29"
  
  # VPC configuration
  vpc_id     = "vpc-0a1bbef550af64d2f"
  vpc_cidr   = "10.29.104.0/22"
  subnet_ids = ["subnet-02d62dcb60871aeab", "subnet-04bb48e5b37a0affe"]
  
  # Node group configuration
  node_group_name = "dev-node-group"
  instance_types  = ["t3.medium"]
  
  # Security group rules
  security_group_ingress_rules = [
    {
      description = "Allow HTTPS from anywhere"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow SSH access"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]  # Restrict SSH to internal network
    },
    {
      description = "Allow custom application port"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["172.16.0.0/12"]
    }
  ]
  
  security_group_egress_rules = [
    {
      description = "Allow all outbound traffic"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  
  # Common tags
  common_tags = {
    Environment = local.environment
    Terraform   = "true"
    Project     = local.cluster_name
    Maintainer  = "Norel Milihov"
  }
} 