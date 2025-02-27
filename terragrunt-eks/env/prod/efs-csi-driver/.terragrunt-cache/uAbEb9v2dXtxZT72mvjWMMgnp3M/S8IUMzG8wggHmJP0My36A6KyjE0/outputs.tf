output "efs_csi_driver_role_arn" {
  description = "The ARN of the EFS CSI Driver IAM role"
  value       = aws_iam_role.efs_csi_driver.arn
}

output "efs_csi_driver_role_name" {
  description = "The name of the EFS CSI Driver IAM role"
  value       = aws_iam_role.efs_csi_driver.name
}

output "storage_class_name" {
  description = "The name of the EFS storage class"
  value       = kubernetes_storage_class.efs.metadata[0].name
} 