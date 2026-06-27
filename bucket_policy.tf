##################################################
#                    PRIMARY                     #
##################################################
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.combined_policy.json

  provider = aws.service-primary
}

data "aws_iam_policy_document" "combined_policy" {
  override_policy_documents = compact([
    var.bucket_policy_document.primary,
    try(data.aws_iam_policy_document.inventory_policy[0].json, null)
  ])

  statement {
    sid       = "DenyNonSSLRequests"
    actions   = ["s3:*"]
    effect    = "Deny"
    resources = [aws_s3_bucket.bucket.arn, "${aws_s3_bucket.bucket.arn}/*"]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  provider = aws.service-primary
}

##################################################
#                   SECONDARY                    #
##################################################
resource "aws_s3_bucket_policy" "this_secondary" {
  count = var.enable_multiregion ? 1 : 0

  bucket = aws_s3_bucket.bucket_secondary[0].id
  policy = data.aws_iam_policy_document.combined_policy_secondary[0].json

  provider = aws.service-secondary
}

data "aws_iam_policy_document" "combined_policy_secondary" {
  count = var.enable_multiregion ? 1 : 0

  source_policy_documents = [
    var.bucket_policy_document.secondary
  ]

  statement {
    sid       = "DenyNonSSLRequests"
    actions   = ["s3:*"]
    effect    = "Deny"
    resources = [aws_s3_bucket.bucket_secondary[0].arn, "${aws_s3_bucket.bucket_secondary[0].arn}/*"]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  provider = aws.service-secondary
}
