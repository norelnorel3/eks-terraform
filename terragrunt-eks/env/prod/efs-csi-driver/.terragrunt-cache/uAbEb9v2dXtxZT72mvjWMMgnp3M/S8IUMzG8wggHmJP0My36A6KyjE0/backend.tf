# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket         = "norel-terragrunt-state"
    dynamodb_table = "norel-terragrunt-locks"
    encrypt        = true
    key            = "env/prod/efs-csi-driver/terraform.tfstate"
    region         = "eu-west-1"
  }
}
