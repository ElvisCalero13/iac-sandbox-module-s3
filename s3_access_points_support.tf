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

  public_access_block_configuration {
    block_public_acls       = lookup(var.s3_access_points[count.index].public_access_block, "block_public_acls", true)
    block_public_policy     = lookup(var.s3_access_points[count.index].public_access_block, "block_public_policy", true)
    ignore_public_acls      = lookup(var.s3_access_points[count.index].public_access_block, "ignore_public_acls", true)
    restrict_public_buckets = lookup(var.s3_access_points[count.index].public_access_block, "restrict_public_buckets", true)
  }

  provider = aws.service-primary
}
