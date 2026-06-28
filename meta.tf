##################################################
#                    PRIMARY                     #
##################################################
data "aws_caller_identity" "main" {
  provider = aws.service-primary
}

data "aws_region" "active" {
  provider = aws.service-primary
}

locals {
  bucket_name = var.append_random_suffix ? "${var.bucket_name}-${random_string.random_suffix.result}" : var.bucket_name

  databricks_full_name  = "${local.bucket_name}-${data.aws_region.active.name}-unity-role"
  databricks_short_name = substr(local.databricks_full_name, 0, 53)
  databricks_role_name  = length(local.databricks_full_name) > 64 ? "${local.databricks_short_name}-unity-role" : local.databricks_full_name

  sse_algorithm = var.enable_sse ? "AES256" : "aws:kms"
  kms_key_arn   = var.enable_sse ? null : var.kms_key_arn.primary
  kms_key_id    = var.enable_sse ? null : var.kms_key_arn.primary
  # kms_key_arn   = var.enable_sse ? null : var.kms_key_arn.primary != null ? var.kms_key_arn.primary : module.bucket_kms_key[0].key_arn
  # kms_key_id    = var.enable_sse ? null : var.kms_key_arn.primary != null ? var.kms_key_arn.primary : module.bucket_kms_key[0].key_id

  enable_object_lock   = var.object_lock_rule.mode != null ? true : false
  inventory_bucket_arn = try(var.inventory.destination.bucket.bucket_arn, null) != null ? var.inventory.destination.bucket.bucket_arn : aws_s3_bucket.bucket.arn
}

##################################################
#                   SECONDARY                    #
##################################################
data "aws_caller_identity" "main_secondary" {
  provider = aws.service-secondary
}

data "aws_region" "active_secondary" {
  provider = aws.service-secondary
}

locals {
  bucket_name_secondary = var.enable_multiregion ? "${var.bucket_name}-${random_string.random_suffix_secondary[0].result}" : ""

  kms_key_arn_secondary = (var.enable_multiregion || var.enable_sse) ? null : var.kms_key_arn.secondary != null ? var.kms_key_arn.secondary : module.bucket_kms_key_secondary[0].key_arn
  kms_key_id_secondary  = (var.enable_multiregion || var.enable_sse) ? null : var.kms_key_arn.secondary != null ? var.kms_key_arn.secondary : module.bucket_kms_key_secondary[0].key_id
}
