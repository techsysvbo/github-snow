variable "bucket_prefix" {
  description = "Prefix used to generate the globally unique S3 bucket name."
  type        = string

  validation {
    condition = (
      length(var.bucket_prefix) >= 3 &&
      length(var.bucket_prefix) <= 36 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_prefix))
    )

    error_message = "bucket_prefix must be 3-36 characters and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "tags" {
  description = "Tags applied to all taggable resources created by this module."
  type        = map(string)
  default     = {}
}