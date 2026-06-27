############################################################
#                       PRIMARY                            #
############################################################

module "bucket_kms_key" {
  count = (var.kms_key_arn.primary == null && !var.enable_sse) ? 1 : 0

  source = "git::https://example.com/terraform-modules/aws-kms-key.git"

  alias_name           = var.bucket_name
  description          = "S3 bucket encryption KMS key"
  append_random_suffix = true
  create_service       = true

  service_key_info = {
    caller_account_ids = [data.aws_caller_identity.main.account_id]
    aws_service_names  = ["s3.${data.aws_region.active.name}.amazonaws.com"]
  }

  inventory_bucket = var.inventory != null ? local.bucket_name : ""
  tags             = var.tags

  providers = {
    aws = aws.service-primary
  }
}

############################################################
#                      SECONDARY                           #
############################################################

module "bucket_kms_key_secondary" {
  count = (var.enable_multiregion && var.kms_key_arn.secondary == null && !var.enable_sse) ? 1 : 0

  source = "git::https://example.com/terraform-modules/aws-kms-key.git"

  alias_name           = local.bucket_name_secondary
  description          = "S3 bucket encryption KMS key"
  append_random_suffix = true
  create_service       = true

  service_key_info = {
    caller_account_ids = [data.aws_caller_identity.main_secondary.account_id]
    aws_service_names  = ["s3.${data.aws_region.active_secondary.name}.amazonaws.com"]
  }

  tags = var.tags

  providers = {
    aws = aws.service-secondary
  }
}
