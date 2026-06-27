resource "aws_iam_policy" "consumers" {
  for_each = var.consumer_policy_actions

  name   = "${var.bucket_name}-${each.key}-${data.aws_region.active.name}"
  policy = data.aws_iam_policy_document.consumers[each.key].json

  provider = aws.service-primary
}

// Create Consumer policies with provided action items
data "aws_iam_policy_document" "consumers" {
  for_each = var.consumer_policy_actions

  policy_id = replace(each.key, "/[^a-zA-Z0-9]/", "")

  statement {
    effect = "Allow"
    sid    = replace(each.key, "/[^a-zA-Z0-9]/", "")
    actions = each.value

    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }

  provider = aws.service-primary
}
