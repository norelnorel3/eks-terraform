# Terragrunt EKS Deployment

## Creator
Norel Milihov

## Overview
This directory contains Terragrunt configurations for deploying and managing an EKS cluster with supporting infrastructure.

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

