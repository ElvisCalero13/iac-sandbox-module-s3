##################################################
#               PRIMARY CLOUDTRAIL               #
##################################################
resource "aws_cloudtrail" "s3_object_events_primary" {
  count = var.enable_cloudtrail ? 1 : 0

  name                          = "${var.bucket_name}-primary-object-events"
  s3_bucket_name                = var.cloudtrail_bucket
  #s3_key_prefix                = "${var.bucket_name}/"
  include_global_service_events = var.is_multi_region_trail
  is_multi_region_trail         = var.is_multi_region_trail
  enable_logging                = true
  enable_log_file_validation    = true

  cloud_watch_logs_group_arn = var.enable_cloudwatch_logs ? "${aws_cloudwatch_log_group.cloudtrail_primary[0].arn}:*" : null
  cloud_watch_logs_role_arn  = var.enable_cloudwatch_logs ? aws_iam_role.cloudtrail_cloudwatch_primary[0].arn : null

  advanced_event_selector {
    name = "S3 Object Events"

    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }

    field_selector {
      field  = "resources.type"
      equals = ["AWS::S3::Object"]
    }

    field_selector {
      field       = "resources.ARN"
      starts_with = ["${aws_s3_bucket.bucket.arn}/"]
    }

    field_selector {
      field  = "eventName"
      equals = ["GetObject", "DeleteObject", "PutObject", "CompleteMultipartUpload", "CopyObject", "DeleteObjects"]
    }
  }

  depends_on = [aws_s3_bucket_notification.eventbridge_primary[0]]
  tags       = var.tags
  provider   = aws.service-primary
}

##################################################
#              SECONDARY CLOUDTRAIL              #
##################################################
resource "aws_cloudtrail" "s3_object_events_secondary" {
  count = var.enable_cloudtrail && var.enable_multiregion ? 1 : 0

  name                          = "${var.bucket_name}-secondary-object-events"
  s3_bucket_name                = var.cloudtrail_bucket_secondary
  #s3_key_prefix                = "${var.bucket_name}/"
  include_global_service_events = var.is_multi_region_trail
  is_multi_region_trail         = var.is_multi_region_trail
  enable_logging                = true
  enable_log_file_validation    = true

  cloud_watch_logs_group_arn = var.enable_cloudwatch_logs_secondary ? "${aws_cloudwatch_log_group.cloudtrail_secondary[0].arn}:*" : null
  cloud_watch_logs_role_arn  = var.enable_cloudwatch_logs_secondary ? aws_iam_role.cloudtrail_cloudwatch_secondary[0].arn : null

  advanced_event_selector {
    name = "S3 Object Events Secondary"

    field_selector {
      field  = "eventCategory"
      equals = ["Data"]
    }

    field_selector {
      field  = "resources.type"
      equals = ["AWS::S3::Object"]
    }

    field_selector {
      field       = "resources.ARN"
      starts_with = ["${aws_s3_bucket.bucket_secondary[0].arn}/"]
    }

    field_selector {
      field  = "eventName"
      equals = ["GetObject", "DeleteObject", "PutObject", "CompleteMultipartUpload", "CopyObject", "DeleteObjects"]
    }
  }

  depends_on = [aws_s3_bucket_notification.eventbridge_secondary[0]]
  tags       = var.tags
  provider   = aws.service-secondary
}
