# EFS Module
module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "1.6.5"

  # File system
  name           = "${var.cluster_name}-efs"
  creation_token = "${var.cluster_name}-efs-token"
  encrypted      = true

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  lifecycle_policy = {
    transition_to_ia = "AFTER_30_DAYS"
  }

  # Mount targets / security group
  mount_targets = {
    for subnet in var.subnet_ids : 
    data.aws_subnet.selected[subnet].availability_zone => {
      subnet_id = subnet
    }
  }
  
  security_group_description = "${var.cluster_name} EFS security group"
  security_group_vpc_id     = var.vpc_id
  
  # Use security group rules with source_security_group_id instead of CIDR blocks
  security_group_rules = {
    eks_cluster = {
      # Allow inbound NFS traffic from EKS cluster security group
      description              = "Allow NFS inbound from EKS cluster"
      type                     = "ingress"
      from_port                = 2049
      to_port                  = 2049
      protocol                 = "tcp"
      source_security_group_id = var.cluster_security_group_id
    }
  }

  # Access point for the storage class
  access_points = {
    sc = {
      name = "sc-access-point"
      posix_user = {
        gid = 1
        uid = 1
      }
      root_directory = {
        path = "/sc"
        creation_info = {
          owner_gid   = 1
          owner_uid   = 1
          permissions = "777"
        }
      }
      tags = {
        Name = "sc-access-point"
      }
    }
  }

  # Backup policy
  enable_backup_policy = true

  tags = var.tags
}

# Get subnet information for availability zones
data "aws_subnet" "selected" {
  for_each = toset(var.subnet_ids)
  id       = each.value
}

# Add policy to node role to allow EFS access
resource "aws_iam_role_policy_attachment" "node_amazon_efs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = var.node_role_name
} 