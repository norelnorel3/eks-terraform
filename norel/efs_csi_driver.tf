# Create service account for EFS CSI Driver
resource "kubernetes_service_account" "efs_csi_controller" {
  metadata {
    name      = "efs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.efs_csi_driver.arn
    }
  }
}

# Create IAM role for EFS CSI Driver
resource "aws_iam_role" "efs_csi_driver" {
  name = "${var.cluster_name}-efs-csi-driver"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:aud": "sts.amazonaws.com",
            "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub": "system:serviceaccount:kube-system:efs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = local.tags
}

# Attach required policies to the IAM role
resource "aws_iam_role_policy_attachment" "efs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.efs_csi_driver.name
}

# Install EFS CSI Driver using Helm
resource "helm_release" "aws_efs_csi_driver" {
  name       = "aws-efs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart      = "aws-efs-csi-driver"
  version    = "2.5.3"

  set {
    name  = "controller.serviceAccount.create"
    value = "false"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = kubernetes_service_account.efs_csi_controller.metadata[0].name
  }

  depends_on = [
    kubernetes_service_account.efs_csi_controller,
    aws_iam_role.efs_csi_driver
  ]
}

# Create StorageClass for EFS
resource "kubernetes_storage_class" "efs" {
  metadata {
    name = "efs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = module.efs.id
    basePath         = "/"
    directoryPerms   = "755"
    gidRangeStart    = "1000"
    gidRangeEnd      = "2000"
  }

  reclaim_policy      = "Delete"
  volume_binding_mode = "Immediate"

  depends_on = [
    helm_release.aws_efs_csi_driver
  ]
}

# Get AWS account ID
data "aws_caller_identity" "current" {} 