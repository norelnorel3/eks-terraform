# Karpenter Helm Release
resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.0.8"

  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password

  values = [
    <<-EOT
    nodeSelector:
      karpenter.sh/controller: 'true'
    dnsPolicy: Default
    webhook:
      enabled: false
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${module.karpenter.iam_role_arn}
    settings:
      clusterName: ${var.cluster_name}
      clusterEndpoint: ${aws_eks_cluster.main.endpoint}
      aws:
        clusterName: ${var.cluster_name}
        clusterEndpoint: ${aws_eks_cluster.main.endpoint}
        defaultInstanceProfile: ${module.karpenter.instance_profile_name}
        interruptionQueueName: ${module.karpenter.queue_name}
    EOT
  ]

  depends_on = [
    aws_eks_cluster.main,
    module.karpenter,
    aws_eks_node_group.main
  ]
}

# Get ECR authorization token
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia  # ECR Public is only available in us-east-1
}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = var.cluster_name
  iam_role_name = "KarpenterController-${var.cluster_name}"
  enable_irsa = true
  node_iam_role_name = "KarpenterNodeRole-${var.cluster_name}"
  create_pod_identity_association = false
  create_instance_profile = true
  enable_spot_termination = true
  create_iam_role = true

  # Configure IRSA
  irsa_oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.karpenter.account_id}:oidc-provider/${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  # Enable v1 permissions which includes unrestricted pricing API access
  enable_v1_permissions = true

  # Add custom policy statements
  # iam_policy_statements = [
  #   {
  #     sid    = "AllowPricingAccess"
  #     effect = "Allow"
  #     actions = [
  #       "pricing:GetProducts",
  #       "pricing:DescribeServices"
  #     ]
  #     resources = ["*"]
  #     condition = {
  #       StringEquals = {
  #         "aws:RequestedRegion": ["us-east-1", "ap-south-1"]
  #       }
  #     }
  #   }
  # ]

  tags = local.tags
}

# Get AWS account ID
data "aws_caller_identity" "karpenter" {}

# Tag subnets for Karpenter discovery
resource "aws_ec2_tag" "subnet_discovery" {
  for_each    = toset(var.subnet_ids)
  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

# Tag security group for Karpenter discovery
resource "aws_ec2_tag" "security_group_discovery" {
  resource_id = aws_security_group.cluster.id
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

# Apply Karpenter EC2NodeClass
resource "kubectl_manifest" "karpenter_nodeclass" {
  yaml_body = templatefile("${path.module}/ec2nodeclass.yaml", {
    cluster_name = var.cluster_name
    node_iam_role_name = module.karpenter.node_iam_role_name
  })

  # Wait 1 minute after Karpenter Helm release
  provisioner "local-exec" {
    command = "sleep 60"
  }

  depends_on = [
    helm_release.karpenter,
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    module.karpenter,
    aws_ec2_tag.subnet_discovery,
    aws_ec2_tag.security_group_discovery
  ]
}

# Apply Karpenter NodePool
resource "kubectl_manifest" "karpenter_nodepool" {
  yaml_body = file("${path.module}/nodepool.yaml")

  # Wait 30 seconds after NodeClass
  provisioner "local-exec" {
    command = "sleep 30"
  }

  depends_on = [
    kubectl_manifest.karpenter_nodeclass,
    helm_release.karpenter,
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    module.karpenter,
    aws_ec2_tag.subnet_discovery,
    aws_ec2_tag.security_group_discovery
  ]
}