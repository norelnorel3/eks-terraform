# EKS Cluster with EFS and Karpenter - Terragrunt Deployment

This repository contains a Terragrunt deployment for an AWS EKS cluster with EFS storage and Karpenter autoscaling.

## Created and Maintained by

**Norel Milihov**

## Overview

This Terragrunt configuration deploys:

- Amazon EKS cluster
- EFS file system with CSI driver
- Karpenter for node autoscaling
- Multi-environment support (dev/prod)

## Components
- EKS Cluster
- EFS Storage
- EFS CSI Driver
- Supporting networking infrastructure

## Prerequisites
- Terraform >= 1.0
- Terragrunt >= 0.45.0
- AWS CLI configured with appropriate credentials
- S3 bucket for remote state (configured in backend.hcl)

## Structure
- `modules/` - Reusable Terraform modules
- `env/` - Environment-specific configurations
  - `dev/` - Development environment
  - `prod/` - Production environment (if applicable)

## License
Copyright © 2023 Norel Milihov. All rights reserved.

