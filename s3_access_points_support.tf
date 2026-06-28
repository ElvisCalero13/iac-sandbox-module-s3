locals {
  s3_access_points_enabled = var.enable_s3_access_points_support
}

resource "aws_s3_access_point" "this" {
  count = local.s3_access_points_enabled ? length(var.s3_access_points) : 0

  name_prefix = var.s3_access_points[count.index].name_prefix
  bucket      = aws_s3_bucket.bucket.id
  vpc_configuration {
    vpc_id = var.s3_access_points[count.index].vpc_id
  }

  policy = var.s3_access_points[count.index].policy

  tags = var.s3_access_points[count.index].tags

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [aws_s3_bucket.bucket]
  provider   = aws.service-primary
}

resource "aws_s3_access_point_public_access_block" "this" {
  count = local.s3_access_points_enabled ? length(var.s3_access_points) : 0

  access_point_arn = aws_s3_access_point.this[count.index].arn

  block_public_acls       = lookup(var.s3_access_points[count.index].public_access_block, "block_public_acls", true)
  block_public_policy     = lookup(var.s3_access_points[count.index].public_access_block, "block_public_policy", true)
  ignore_public_acls      = lookup(var.s3_access_points[count.index].public_access_block, "ignore_public_acls", true)
  restrict_public_buckets = lookup(var.s3_access_points[count.index].public_access_block, "restrict_public_buckets", true)

  provider = aws.service-primary
}
