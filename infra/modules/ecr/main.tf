module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
#   version = "~> 1.0"

  repository_name                 = var.repository_name
  repository_force_delete         = true
  repository_image_scan_on_push   = true
  repository_image_tag_mutability = "MUTABLE"

  repository_encryption_configuration = {
    encryption_type = "KMS"
  }
}
