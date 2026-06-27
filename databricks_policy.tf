data "aws_iam_policy_document" "trusted-policy-databricks_bucket" {
  count = var.enable_databricks ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVK0TYTL"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.databricks_external_id]
    }
  }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::${data.aws_caller_identity.main.account_id}:role/${local.databricks_role_name}"]
    }
  }

  provider = aws.service-primary
}

resource "aws_iam_role" "iam-role-bucket" {
  count = var.enable_databricks ? 1 : 0

  name               = local.databricks_role_name
  assume_role_policy = data.aws_iam_policy_document.trusted-policy-databricks_bucket[0].json

  provider = aws.service-primary
}

resource "aws_iam_policy" "iam-policy-bucket" {
  count = var.enable_databricks ? 1 : 0

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "${local.bucket_name}-unity-pol",
    Statement = concat(
      [
        {
          Sid = "s3PipelinesUnity",
          Action = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject",
            "s3:ListBucket",
            "s3:GetBucketLocation"
          ],
          Resource = [
            "arn:aws:s3:::${aws_s3_bucket.bucket.id}",
            "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*"
          ],
          Effect = "Allow"
        }
      ],
      local.kms_key_arn != null ? [{
        Sid = "kmsPipelinesUnity",
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey*"
        ],
        Resource = [local.kms_key_arn],
        Effect = "Allow"
      }] : [],
      [
        {
          Sid = "AssumeRolePipeline",
          Action = ["sts:AssumeRole"],
          Resource = [aws_iam_role.iam-role-bucket[0].arn],
          Effect = "Allow"
        }
      ]
    )
  })

  provider = aws.service-primary
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  count = var.enable_databricks ? 1 : 0

  role       = aws_iam_role.iam-role-bucket[0].name
  policy_arn = aws_iam_policy.iam-policy-bucket[0].arn

  provider = aws.service-primary
}
