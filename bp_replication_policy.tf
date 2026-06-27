data "aws_iam_policy_document" "bp_s3_replication_pol_doc" {
  count = var.bp_replication != null ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = [
        "s3.amazonaws.com"
      ]
      type = "Service"
    }
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.bp_replication.account_id}:root"]
    }
  }

  provider = aws.service-primary
}

resource "aws_iam_policy" "bp_s3_replication_pol" {
  count = var.bp_replication != null ? 1 : 0

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.bucket_name}-pol"
    Statement = [
      {
        "Sid" : "SourceBucketPermissions",
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObjectRetention",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectVersionAcl",
          "s3:ListBucket",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectLegalHold",
          "s3:GetReplicationConfiguration",
          "s3:PutInventoryConfiguration",
          "s3:PutObject",
          "s3:PutReplicationConfiguration",
          "s3:InitiateReplication",
          "s3:ObjectOwnerOverrideToBucketOwner",
          "s3:ReplicateObject",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:GetObjectTagging",
          "s3:ListBucket",
          "s3:GetObjectVersion"
        ],
        "Resource" : [
          "${aws_s3_bucket.bucket.arn}",
          "${aws_s3_bucket.bucket.arn}/*",
        ]
      },
      {
        "Sid" : "DestinationBucketPermissions",
        "Effect" : "Allow",
        "Action" : [
          "s3:ReplicateObject",
          "s3:ObjectOwnerOverrideToBucketOwner",
          "s3:GetObjectVersionTagging",
          "s3:ReplicateTags",
          "s3:ReplicateDelete",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectTagging",
          "s3:ListBucket",
          "s3:GetReplicationConfiguration",
          "s3:PutInventoryConfiguration",
          "s3:InitiateReplication",
          "s3:ReplicateObject"
        ],
        "Resource" : [
          "${var.bp_replication.bucket_arn}/*",
        ]
      }
    ]
  })

  provider = aws.service-primary
}

resource "aws_iam_role" "bp_s3_replication_role" {
  count = var.bp_replication != null ? 1 : 0

  name               = "${var.bucket_name}-role"
  assume_role_policy = data.aws_iam_policy_document.bp_s3_replication_pol_doc[0].json
  managed_policy_arns = [aws_iam_policy.bp_s3_replication_pol[0].arn]

  provider = aws.service-primary
}

#Replication to BP pro_bucket
resource "aws_s3_bucket_replication_configuration" "replication_to_bp_pro" {
  count = var.bp_replication != null ? 1 : 0

  role   = aws_iam_role.bp_s3_replication_role[0].arn
  bucket = aws_s3_bucket.bucket.id

  rule {
    id       = "Replication_to_BP_pro"
    priority = 1
    status   = "Enabled"
    delete_marker_replication {
      status = "Enabled"
    }
    filter {
      prefix = "data/pro/deuna_bp/"
    }
    destination {
      account       = var.bp_replication.account_id
      bucket        = var.bp_replication.bucket_arn
      storage_class = "STANDARD"
      access_control_translation {
        owner = "Destination"
      }
    }
  }

  rule {
    id       = "Replication_to_BP_raw"
    priority = 2
    status   = "Enabled"
    delete_marker_replication {
      status = "Enabled"
    }
    filter {
      prefix = "data/raw/deuna_bp/"
    }
    destination {
      account       = var.bp_replication.account_id
      bucket        = var.bp_replication.bucket_arn
      storage_class = "STANDARD"
      access_control_translation {
        owner = "Destination"
      }
    }
  }

  provider = aws.service-primary
}
