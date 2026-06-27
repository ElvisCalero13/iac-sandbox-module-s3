output "bucket_id" {
  description = "S3 Bucket Id"
  value       = aws_s3_bucket.bucket.id
}

output "bucket_arn" {
  description = "S3 Bucket ARN"
  value       = aws_s3_bucket.bucket.arn
}

output "bucket_domain_name" {
  description = "S3 Bucket Domain Name"
  value       = aws_s3_bucket.bucket.bucket_domain_name
}

output "bucket_name" {
  description = "S3 Bucket Name"
  value       = aws_s3_bucket.bucket.bucket
}

output "consumer_policies" {
  description = "S3 Bucket Consumer Policies name and ARN map"
  value = {
    for name, policy in aws_iam_policy.consumers : name => policy.arn
  }
}

output "bucket_kms_key_id" {
  description = "S3 Bucket KMS Key ID"
  value       = local.kms_key_id
}

output "bucket_kms_key_arn" {
  description = "S3 Bucket KMS Key ARN"
  value       = local.kms_key_arn
}

output "bucket" {
  description = "S3 bucket details"

  value = merge(
    {
      primary = {
        id      = aws_s3_bucket.bucket.id
        name    = aws_s3_bucket.bucket.bucket
        arn     = aws_s3_bucket.bucket.arn
        domain  = aws_s3_bucket.bucket.bucket_domain_name
        kms_id  = local.kms_key_id
        kms_arn = local.kms_key_arn
      }
    },
    var.enable_multiregion ? {
      secondary = {
        id      = aws_s3_bucket.bucket_secondary[0].id
        name    = aws_s3_bucket.bucket_secondary[0].bucket
        arn     = aws_s3_bucket.bucket_secondary[0].arn
        domain  = aws_s3_bucket.bucket_secondary[0].bucket_domain_name
        kms_id  = local.kms_key_id_secondary
        kms_arn = local.kms_key_arn_secondary
      }
    } : {}
  )
}

output "cloudtrail_arn_primary" {
  description = "CloudTrail ARN for primary S3 bucket object events"
  value       = var.enable_cloudtrail ? aws_cloudtrail.s3_object_events_primary[0].arn : null
}

output "cloudtrail_arn_secondary" {
  description = "CloudTrail ARN for secondary S3 bucket object events"
  value       = var.enable_cloudtrail && var.enable_multiregion ? aws_cloudtrail.s3_object_events_secondary[0].arn : null
}
