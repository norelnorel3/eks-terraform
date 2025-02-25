# Node Group Resources
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids
  capacity_type   = "SPOT"         # Use Spot instances

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

  # Add launch template with naming
  launch_template {
    id      = aws_launch_template.node_group.id
    version = aws_launch_template.node_group.latest_version
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

# Create launch template for node group naming
resource "aws_launch_template" "node_group" {
  name_prefix = "${var.cluster_name}-node-launch-template"
  
  # Instance type configuration
  instance_type = var.instance_types[0]  # Use the first instance type from the list
  
  # EBS configuration
  block_device_mappings {
    device_name = "/dev/xvda"
    
    ebs {
      volume_size = 20
      volume_type = "gp3"
      delete_on_termination = true
    }
  }
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-worker"
    }
  }
  
  # Add additional tags for all resources created by this template
  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "${var.cluster_name}-worker-volume"
    }
  }
} 