include "env" {
  path = "../prod.hcl"
  expose = true  
}

include "root" {
  path = "../../../root.hcl"
  expose = true  
}

terraform {
  source = "../../../modules/efs-csi-driver"
}

dependency "eks" {
  config_path = "../eks"
  
  mock_outputs = {
    cluster_endpoint = "https://mock-endpoint"
    cluster_certificate_authority_data = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN5RENDQWJDZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJek1USXhOVEUxTURNd01Gb1hEVE16TVRJeE1qRTFNRE13TUZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTXJyCnhiQ0JEOEhQWUZUZHVXSzJ1K1NSdnNmWlhhUlJGcG9EK2RoZ0RNM3dGZGVkTGt3ZUhQY3ZGM0Y0Q0FkTWFWZ0YKbDVLZFZkNUVKOHRQcmJEU3hxUElHU1Q3QmhPRUlzYkNzTkRXVWNGa3ZhS0VqL2FKTEVrNUNtNWl5Y0NJUWNJRQpyUmw1ZHNtUEVYZ1Jqa1VqL0pXZW1yUXdxcnMxRGVGOEFXR0VrSnFoRGZxNy9kTTBNVnB5T1YrUk1kQUlDCnNzSzVCMkJKK0RFRGxKL0ZQYUd6V2NTUUVOTFVjUkxzU0JuZEJ5RnZXZUx1Q0E9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
    oidc_provider_url = "https://mock-oidc"
    efs_id = "mock-efs-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

dependency "efs" {
  config_path = "../efs"
  
  mock_outputs = {
    id = "mock-efs-id"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}


inputs = {
  cluster_name            = include.env.locals.cluster_name
  cluster_endpoint        = dependency.eks.outputs.cluster_endpoint
  cluster_ca_certificate  = dependency.eks.outputs.cluster_certificate_authority_data
  oidc_provider_url      = dependency.eks.outputs.oidc_provider_url
  efs_id                 = dependency.efs.outputs.id
  tags                   = include.env.locals.common_tags
}

