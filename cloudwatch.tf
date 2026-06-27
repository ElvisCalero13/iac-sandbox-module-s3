##################################################
#                 PRIMARY CLOUDWATCH             #
##################################################
resource "aws_cloudwatch_log_group" "cloudtrail_primary" {
  count             = var.enable_cloudwatch_logs && var.enable_cloudtrail ? 1 : 0
  name              = var.cloudwatch_log_group_name
  retention_in_days = 30
  tags              = var.tags
  provider          = aws.service-primary
}

resource "aws_iam_role" "cloudtrail_cloudwatch_primary" {
  count = var.enable_cloudwatch_logs && var.enable_cloudtrail ? 1 : 0
  name  = "${var.bucket_name}-cloudtrail-cloudwatch-primary-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags     = var.tags
  provider = aws.service-primary
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch_primary" {
  count = var.enable_cloudwatch_logs && var.enable_cloudtrail ? 1 : 0
  name  = "${var.bucket_name}-cloudtrail-cloudwatch-primary-policy"
  role  = aws_iam_role.cloudtrail_cloudwatch_primary[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail_primary[0].arn}:*"
      }
    ]
  })

  provider = aws.service-primary
}

##################################################
#                SECONDARY CLOUDWATCH            #
##################################################
resource "aws_cloudwatch_log_group" "cloudtrail_secondary" {
  count             = var.enable_cloudwatch_logs && var.enable_cloudtrail && var.enable_multiregion ? 1 : 0
  name              = var.cloudwatch_log_group_name_secondary
  retention_in_days = 30
  tags              = var.tags
  provider          = aws.service-secondary
}

resource "aws_iam_role" "cloudtrail_cloudwatch_secondary" {
  count = var.enable_cloudwatch_logs && var.enable_cloudtrail && var.enable_multiregion ? 1 : 0
  name  = "${var.bucket_name}-cloudtrail-cloudwatch-secondary-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags     = var.tags
  provider = aws.service-secondary
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch_secondary" {
  count = var.enable_cloudwatch_logs && var.enable_cloudtrail && var.enable_multiregion ? 1 : 0
  name  = "${var.bucket_name}-cloudtrail-cloudwatch-secondary-policy"
  role  = aws_iam_role.cloudtrail_cloudwatch_secondary[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail_secondary[0].arn}:*"
      }
    ]
  })

  provider = aws.service-secondary
}
