variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "Cluster CA certificate for EKS"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC Provider"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for Karpenter to use"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "Security group ID of the EKS cluster"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
} 