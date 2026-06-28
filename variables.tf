variable "bucket_name" {
  description = "The name of the bucket"
  type        = string
}

variable "append_random_suffix" {
  description = "[Optional] Append random string as suffix, to create unique S3 bucket name. Default set to true"
  type        = bool
  default     = true
}

variable "force_s3_destroy" {
  description = "[Optional] Force destruction of the S3 bucket when the stack is deleted"
  type        = string
  default     = false
}

variable "consumer_policy_actions" {
  description = "[Optional] Map of multiple S3 consumer policies to be applied to bucket e.g. {EC2Read = [s3:GetObject]}"
  type        = map(list(string))
  default     = {}
}

variable "folder_names" {
  description = "[Optional] List of folder names to be created in the S3 bucket. Will create .keep file in each folder"
  type        = list(string)
  default     = []
}

variable "enable_versioning" {
  description = "Should versioning be enabled? (true/false)"
  type        = bool
  default     = true
}

variable "versioning_status" {
  description = "[Optional] It will Enable/Disable/Suspended object versioning."
  type        = string
  default     = "Enabled"

  validation {
    condition     = var.versioning_status == null ? true : contains(["Enabled", "Suspended", "Disabled"], var.versioning_status)
    error_message = "Valid values for versioning_status are Enabled, Suspended and Disabled."
  }
}

variable "lifecycle_rules" {
  description = "[Optional] List of lifecycle rules to transition or expire objects."
  type = list(object({
    rule_name                            = string
    transition_class                     = optional(string, null)
    transition_days                      = optional(number, null)
    filter_prefix                        = optional(string, null)
    filter_tags                          = optional(map(string), null)
    expiration_days                      = optional(number, null)
    incomplete_multipart_expiration_days = optional(number, null)
    noncurrent_version_expiration_days   = optional(number, null)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.lifecycle_rules :
      rule.transition_class == null ? true : contains([
        "STANDARD_IA", "ONEZONE_IA", "INTELLIGENT_TIERING",
        "GLACIER", "DEEP_ARCHIVE", "GLACIER_IR"
      ], rule.transition_class)
    ])
    error_message = "Valid storage classes are: STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER, DEEP_ARCHIVE, GLACIER_IR."
  }
}

variable "tags" {
  description = "[Optional] Custom tags which can be passed on to the bucket"
  type        = map(string)
  default     = {}
}

variable "object_tags" {
  description = "[Optional] Custom tags which can be passed on to the bucket objects"
  type        = map(string)
  default     = {}
}

variable "bucket_policy_document" {
  description = "[Optional] Additional Bucket Policy JSON document."
  type = object({
    primary   = string
    secondary = optional(string, "{}")
  })
  default = {
    primary   = "{}"
    secondary = "{}"
  }
}

variable "object_lock_rule" {
  description = "[Optional] Enable Object Lock rule configuration. Use in conjunction with object lock."
  type = object({
    mode           = string #Valid values are GOVERNANCE and COMPLIANCE
    retention_days = number
  })
  default = {
    mode           = null
    retention_days = 0
  }

  validation {
    condition     = var.object_lock_rule.mode == null ? true : contains(["GOVERNANCE", "COMPLIANCE"], var.object_lock_rule.mode)
    error_message = "Valid values for object-lock mode are GOVERNANCE and COMPLIANCE."
  }
}

variable "kms_key_arn" {
  description = "[Optional] ARN of the KMS Key to use for object encryption. By default, it creates a KMS key."
  type = object({
    primary   = string
    secondary = optional(string, null)
  })
  default = {
    primary   = null
    secondary = null
  }
}

variable "logging" {
  description = "[Optional] Bucket access logging configuration."
  type = object({
    bucket_name = string
    prefix      = string
  })
  default = null
}

variable "notifications" {
  description = "[Optional] Bucket sns notification configuration."
  type = object({
    aws_sns_topic = string
    events        = list(string)
    filter_suffix = string
    eventbridge   = optional(bool, false)
  })
  default = null
}

variable "cors_rule" {
  description = "[Optional] Allowed origin for CORS backoffice bucket"
  type = object({
    allowed_headers = optional(list(string), ["*"])
    allowed_methods = optional(list(string), ["PUT", "GET"])
    allowed_origins = optional(list(string), ["*"])
    expose_headers  = optional(list(string), [])
    max_age_seconds = optional(number, 3000)
  })
  default = null
}

variable "enable_sse" {
  description = "[Optional] Enable Server Side Encryption. Default is disabled."
  type        = bool
  default     = false
}

variable "enable_databricks" {
  description = "[Optional] Enable Databricks. Default is disabled."
  type        = bool
  default     = false
}

variable "databricks_external_id" {
  description = "[Optional] Databricks AWS account ID"
  type        = string
  default     = "044f9dc8-739e-4bed-bdc8-7ccf34f39d56"
}

variable "enable_multiregion" {
  description = "[Optional] Enable Multiregion. Default is disabled."
  type        = bool
  default     = false
}

variable "replication_status" {
  description = "[Optional] Enable Replication. Default is enabled."
  type        = string
  default     = "Enabled"

  validation {
    condition     = var.replication_status == null ? true : contains(["Enabled", "Disabled"], var.replication_status)
    error_message = "Valid values for replication status are Enabled and Disabled."
  }
}

variable "inventory" {
  description = "S3 bucket inventory configuration settings"
  type = object({
    name = string
    destination = object({
      bucket = object({
        format     = optional(string, "Parquet")
        bucket_arn = optional(string, null)
        prefix     = optional(string, null)
      })
    })
    schedule = object({
      frequency = optional(string, "Daily")
    })
    included_object_versions = optional(string, "Current")
    optional_fields          = optional(list(string), [])
  })
  default = null
}

variable "bp_replication" {
  description = "BP replication configuration"
  type = object({
    bucket_arn = string
    account_id = string
  })
  default = null
}

##################################################
#                    CLOUDTRAIL                  #
##################################################
variable "enable_cloudtrail" {
  description = "Enable CloudTrail for S3 object-level events"
  type        = bool
  default     = false
}

variable "cloudtrail_bucket" {
  description = "S3 bucket name for CloudTrail logs (required if enable_cloudtrail is true)"
  type        = string
  default     = ""
}

variable "is_multi_region_trail" {
  description = "Enable multi-region trail for S3 events across all regions"
  type        = bool
  default     = false
}

variable "cloudtrail_bucket_secondary" {
  description = "S3 bucket name for secondary CloudTrail logs"
  type        = string
  default     = ""
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch Logs for primary CloudTrail"
  type        = bool
  default     = false
}

variable "enable_cloudwatch_logs_secondary" {
  description = "Enable CloudWatch Logs for primary CloudTrail"
  type        = bool
  default     = false
}

variable "cloudwatch_log_group_name" {
  description = "CloudWatch Log Group name for primary CloudTrail logs"
  type        = string
  default     = ""
}

variable "cloudwatch_log_group_name_secondary" {
  description = "CloudWatch Log Group name for primary CloudTrail logs"
  type        = string
  default     = ""
}


variable "enable_s3_access_points_support" {
  description = "Feature flag to enable S3 Access Points support"
  type        = bool
  default     = false
}
