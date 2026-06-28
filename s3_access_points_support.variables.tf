variable "enable_s3_access_points_support" {
  description = "Feature flag to enable S3 Access Points support"
  type        = bool
  default     = false
}

variable "s3_access_points" {
  description = "[Optional] List of S3 Access Points configurations"
  type = list(object({
    name   = string
    vpc_id = optional(string)
    policy = optional(string)
    public_access_block = optional(object({
      block_public_acls       = optional(bool, true)
      block_public_policy     = optional(bool, true)
      ignore_public_acls      = optional(bool, true)
      restrict_public_buckets = optional(bool, true)
    }), null)
  }))
  default = []
}
