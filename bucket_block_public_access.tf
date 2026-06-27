##################################################
#                    PRIMARY                     #
##################################################
resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  provider = aws.service-primary
}

##################################################
#                   SECONDARY                    #
##################################################
resource "aws_s3_bucket_public_access_block" "bucket_secondary" {
  count = var.enable_multiregion ? 1 : 0

  bucket = aws_s3_bucket.bucket_secondary[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  provider = aws.service-secondary
}
