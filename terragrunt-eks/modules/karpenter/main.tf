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
      clusterEndpoint: ${var.cluster_endpoint}
      aws:
        clusterName: ${var.cluster_name}
        clusterEndpoint: ${var.cluster_endpoint}
        defaultInstanceProfile: ${module.karpenter.instance_profile_name}
        interruptionQueueName: ${module.karpenter.queue_name}
    EOT
  ]

  depends_on = [
    module.karpenter  # This ensures IAM roles are created first
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
  irsa_oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.karpenter.account_id}:oidc-provider/${replace(var.oidc_provider_url, "https://", "")}"
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  # Enable v1 permissions which includes unrestricted pricing API access
  enable_v1_permissions = true

  tags = var.tags
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
  resource_id = var.cluster_security_group_id
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

# Apply Karpenter EC2NodeClass
resource "kubectl_manifest" "karpenter_nodeclass" {
  yaml_body = templatefile("${path.module}/templates/ec2nodeclass.yaml", {
    cluster_name = var.cluster_name
    node_iam_role_name = module.karpenter.node_iam_role_name
  })

  depends_on = [
    helm_release.karpenter
  ]
}

# Apply Karpenter NodePool
resource "kubectl_manifest" "karpenter_nodepool" {
  yaml_body = file("${path.module}/templates/nodepool.yaml")

  depends_on = [
    kubectl_manifest.karpenter_nodeclass
  ]
} 