variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the nodes/node groups will be deployed"
  type        = list(string)
}

variable "node_group_name" {
  description = "Name of the node group"
  type        = string
}

variable "instance_types" {
  description = "List of instance types for the node group"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "ingress_rules" {
  description = "List of ingress rules to create for the cluster security group"
  type = list(object({
    description = optional(string)
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "Allow HTTPS from anywhere"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "egress_rules" {
  description = "List of egress rules to create for the cluster security group"
  type = list(object({
    description = optional(string)
    from_port   = optional(number)
    to_port     = optional(number)
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "Allow all outbound traffic"
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
} 