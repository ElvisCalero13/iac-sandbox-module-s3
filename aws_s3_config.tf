########################################################
#                       PRIMARY                        #
########################################################
resource "aws_s3_bucket_versioning" "s3_bucket_versioning" {
  count = var.enable_versioning ? 1 : 0

  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = var.versioning_status
  }

  provider = aws.service-primary
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_ownership_control" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  provider = aws.service-primary
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    bucket_key_enabled = var.enable_sse ? true : null
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.sse_algorithm
      kms_master_key_id = local.kms_key_arn
    }
  }

  provider = aws.service-primary
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_bucket_lifecycle_configuration" {
  count = length(var.lifecycle_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.bucket.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.rule_name
      status = "Enabled"

      dynamic "transition" {
        for_each = rule.value.transition_class != null ? [1] : []
        content {
          days          = rule.value.transition_days
          storage_class = rule.value.transition_class
        }
      }

      dynamic "filter" {
        for_each = rule.value.filter_prefix != null ? [1] : []
        content {
          prefix = rule.value.filter_prefix
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration_days != null ? [1] : []
        content {
          days = rule.value.expiration_days
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.incomplete_multipart_expiration_days != null ? [1] : []
        content {
          days_after_initiation = rule.value.incomplete_multipart_expiration_days
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration_days != null ? [1] : []
        content {
          noncurrent_days = rule.value.noncurrent_version_expiration_days
        }
      }
    }
  }

  provider = aws.service-primary
}

resource "aws_s3_bucket_object_lock_configuration" "s3_bucket_object_lock_configuration" {
  count = local.enable_object_lock ? 1 : 0

  bucket = aws_s3_bucket.bucket.id
  rule {
    default_retention {
      mode = var.object_lock_rule.mode
      days = var.object_lock_rule.retention_days
    }
  }

  provider = aws.service-primary
}

########################################################
#                       SECONDARY                      #
########################################################
resource "aws_s3_bucket_versioning" "s3_bucket_versioning_secondary" {
  count = (var.enable_multiregion && var.enable_versioning) ? 1 : 0

  bucket = aws_s3_bucket.bucket_secondary[0].id
  versioning_configuration {
    status = var.versioning_status
  }

  provider = aws.service-secondary
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_ownership_control_secondary" {
  count = var.enable_multiregion ? 1 : 0

  bucket = aws_s3_bucket.bucket_secondary[0].id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }

  provider = aws.service-secondary
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_server_side_encryption_configuration_secondary" {
  count = var.enable_multiregion ? 1 : 0

  bucket = aws_s3_bucket.bucket_secondary[0].id
  rule {
    bucket_key_enabled = var.enable_sse ? true : null
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.sse_algorithm
      kms_master_key_id = local.kms_key_arn_secondary
    }
  }

  provider = aws.service-secondary
}

resource "aws_s3_bucket_lifecycle_configuration" "s3_bucket_lifecycle_configuration_secondary" {
  count = (var.enable_multiregion && length(var.lifecycle_rules) > 0) ? 1 : 0

  bucket = aws_s3_bucket.bucket_secondary[0].id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = rule.value.rule_name
      status = "Enabled"

      dynamic "transition" {
        for_each = rule.value.transition_class != null ? [1] : []
        content {
          days          = rule.value.transition_days
          storage_class = rule.value.transition_class
        }
      }

      dynamic "filter" {
        for_each = rule.value.filter_prefix != null ? [1] : []
        content {
          prefix = rule.value.filter_prefix
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration_days != null ? [1] : []
        content {
          days = rule.value.expiration_days
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.incomplete_multipart_expiration_days != null ? [1] : []
        content {
          days_after_initiation = rule.value.incomplete_multipart_expiration_days
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration_days != null ? [1] : []
        content {
          noncurrent_days = rule.value.noncurrent_version_expiration_days
        }
      }
    }
  }

  provider = aws.service-secondary
}

resource "aws_s3_bucket_object_lock_configuration" "s3_bucket_object_lock_configuration_secondary" {
  count = (var.enable_multiregion && local.enable_object_lock) ? 1 : 0

  bucket = aws_s3_bucket.bucket_secondary[0].id
  rule {
    default_retention {
      mode = var.object_lock_rule.mode
      days = var.object_lock_rule.retention_days
    }
  }

  provider = aws.service-secondary
}
