# Node Group Resources
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.instance_types
  ami_type        = "AL2_x86_64"  # Amazon Linux 2 AMI
  capacity_type   = "SPOT"         # Use Spot instances
  disk_size       = 20             # Root EBS volume size in GB

  scaling_config {
    desired_size = 3
    max_size     = 5
    min_size     = 1
  }

  # Add labels for node naming
  labels = {
    "karpenter.sh/controller" = "true"
    "Name" = "${var.cluster_name}-worker"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.main
  ]

  tags = {
    "Name" = "${var.cluster_name}-worker"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "eks:cluster-name" = var.cluster_name
    "eks:nodegroup-name" = var.node_group_name
  }

  # Add lifecycle block to prevent accidental deletion
  lifecycle {
    create_before_destroy = true
  }
}

# Node Group IAM Role
resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com",
            "eks.amazonaws.com"
          ]
        }
      }
    ]
  })

  tags = {
    "Name" = "${var.cluster_name}-node-role"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
} 