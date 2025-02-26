output "id" {
  description = "The ID of the EFS file system"
  value       = module.efs.id
}

output "arn" {
  description = "The ARN of the EFS file system"
  value       = module.efs.arn
}

output "dns_name" {
  description = "The DNS name of the EFS file system"
  value       = module.efs.dns_name
}

output "security_group_id" {
  description = "The ID of the EFS security group"
  value       = module.efs.security_group_id
}

output "access_point_id" {
  description = "The ID of the EFS access point"
  value       = module.efs.access_points["sc"].id
} 