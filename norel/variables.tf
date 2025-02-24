variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "norel-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster will be deployed"
  type        = string
  default     = "vpc-0a1bbef550af64d2f"
}

variable "subnet_ids" {
  description = "List of subnet IDs where the nodes/node groups will be deployed"
  type        = list(string)
  default     = ["subnet-02d62dcb60871aeab", "subnet-04bb48e5b37a0affe"]
}

variable "node_group_name" {
  description = "Name of the node group"
  type        = string
  default     = "norel-node-group"
}

variable "instance_types" {
  description = "List of instance types for the node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.29.104.0/22"  # Make sure this matches your VPC CIDR
} 