###############################################
#                 PRIMARY
###############################################

resource "aws_s3_bucket" "bucket" {
  bucket              = local.bucket_name
  object_lock_enabled = local.enable_object_lock

  force_destroy = var.force_s3_destroy

  tags = merge({
    Name = local.bucket_name
  }, var.tags)

  provider = aws.service-primary
}

resource "random_string" "random_suffix" {
  length  = 12
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "aws_s3_bucket_logging" "default" {
  count = var.logging != null ? 1 : 0

  bucket        = aws_s3_bucket.bucket.id
  target_bucket = var.logging.bucket_name
  target_prefix = var.logging.prefix

  provider = aws.service-primary
}

resource "aws_s3_bucket_notification" "default" {
  count = var.notifications != null ? 1 : 0

  bucket      = aws_s3_bucket.bucket.id
  eventbridge = var.notifications.eventbridge

  topic {
    topic_arn     = var.notifications.aws_sns_topic
    events        = var.notifications.events
    filter_suffix = var.notifications.filter_suffix
  }

  provider = aws.service-primary
}

resource "aws_s3_bucket_cors_configuration" "cors-policy" {
  count = var.cors_rule != null ? 1 : 0

  bucket = aws_s3_bucket.bucket.id

  cors_rule {
    allowed_headers = var.cors_rule.allowed_headers
    allowed_methods = var.cors_rule.allowed_methods
    allowed_origins = var.cors_rule.allowed_origins
    expose_headers  = var.cors_rule.expose_headers
    max_age_seconds = var.cors_rule.max_age_seconds
  }

  provider = aws.service-primary
}

resource "aws_s3_bucket_notification" "eventbridge_primary" {
  count = var.enable_cloudtrail && var.notifications == null ? 1 : 0

  bucket      = aws_s3_bucket.bucket.id
  eventbridge = true

  provider = aws.service-primary
}

###############################################
#                 SECONDARY
###############################################

resource "aws_s3_bucket" "bucket_secondary" {
  count = var.enable_multiregion ? 1 : 0

  bucket              = local.bucket_name_secondary
  object_lock_enabled = local.enable_object_lock
  force_destroy       = var.force_s3_destroy

  tags = merge({
    Name = local.bucket_name_secondary
  }, var.tags)

  provider = aws.service-secondary
}

resource "random_string" "random_suffix_secondary" {
  count = var.enable_multiregion ? 1 : 0

  length  = 12
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "aws_s3_bucket_logging" "default_secondary" {
  count = (var.enable_multiregion && var.logging != null) ? 1 : 0

  bucket        = aws_s3_bucket.bucket_secondary[0].id
  target_bucket = var.logging.bucket_name
  target_prefix = var.logging.prefix

  provider = aws.service-secondary
}

# Notification resource intentionally commented as shown in screenshot.

resource "aws_s3_bucket_cors_configuration" "cors-policy_secondary" {
  count = (var.enable_multiregion && var.cors_rule != null) ? 1 : 0

  bucket = aws_s3_bucket.bucket_secondary[0].id

  cors_rule {
    allowed_headers = var.cors_rule.allowed_headers
    allowed_methods = var.cors_rule.allowed_methods
    allowed_origins = var.cors_rule.allowed_origins
    expose_headers  = var.cors_rule.expose_headers
    max_age_seconds = var.cors_rule.max_age_seconds
  }

  provider = aws.service-secondary
}

resource "aws_s3_bucket_notification" "eventbridge_secondary" {
  count = var.enable_multiregion && var.enable_cloudtrail && var.notifications == null ? 1 : 0

  bucket      = aws_s3_bucket.bucket_secondary[0].id
  eventbridge = true

  provider = aws.service-secondary
}
