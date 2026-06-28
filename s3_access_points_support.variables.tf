variable "enable_s3_access_points_support" {
  description = "Feature flag to enable S3 Access Points support. Disabled by default."
  type        = bool
  default     = false
}

variable "s3_access_points" {
  description = "[Optional] List of S3 Access Points configurations to create. Only applied if enable_s3_access_points_support is true."
  type = list(object({
    name_prefix = string
    vpc_id      = string
    policy      = optional(string, null)
    public_access_block = optional(object({
      block_public_acls       = optional(bool, true)
      block_public_policy     = optional(bool, true)
      ignore_public_acls      = optional(bool, true)
      restrict_public_buckets = optional(bool, true)
    }), null)
    tags = optional(map(string), {})
  }))
  default = []
}
