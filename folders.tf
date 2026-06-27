resource "aws_s3_object" "main" {
  count = length(var.folder_names)

  bucket                 = aws_s3_bucket.bucket.bucket
  key                    = "${var.folder_names[count.index]}/.keep"
  kms_key_id             = local.kms_key_arn
  server_side_encryption = local.sse_algorithm

  tags = merge({
    Name = "${var.bucket_name}-${var.folder_names[count.index]}"
  }, var.object_tags)

  provider = aws.service-primary
}
