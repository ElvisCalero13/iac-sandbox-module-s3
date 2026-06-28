locals {
  s3_access_points_enabled = var.enable_s3_access_points_support
}

resource "aws_s3_access_point" "this" {
  count = local.s3_access_points_enabled ? length(var.s3_access_points) : 0

  name   = var.s3_access_points[count.index].name
  bucket = aws_s3_bucket.bucket.id

  vpc_configuration {
    vpc_id = lookup(var.s3_access_points[count.index], "vpc_id", null)
  }

  policy = lookup(var.s3_access_points[count.index], "policy", null)

  dynamic "public_access_block" {
    for_each = var.s3_access_points[count.index].public_access_block != null ? [var.s3_access_points[count.index].public_access_block] : []
    content {
      block_public_acls       = lookup(public_access_block.value, "block_public_acls", true)
      block_public_policy     = lookup(public_access_block.value, "block_public_policy", true)
      ignore_public_acls      = lookup(public_access_block.value, "ignore_public_acls", true)
      restrict_public_buckets = lookup(public_access_block.value, "restrict_public_buckets", true)
    }
  }

  provider = aws.service-primary
}
