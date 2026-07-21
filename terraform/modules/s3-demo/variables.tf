variable "bucket_name" {
  description = "Exact S3 bucket name supplied by the GitHub production environment."
  type        = string

  validation {
    condition = (
      length(var.bucket_name) >= 3 &&
      length(var.bucket_name) <= 63 &&
      can(regex(
        "^[a-z0-9][a-z0-9.-]*[a-z0-9]$",
        var.bucket_name
      ))
    )

    error_message = "bucket_name must be a valid S3 bucket name containing 3-63 lowercase letters, numbers, periods, or hyphens."
  }
}

variable "tags" {
  description = "Standard VBO tags applied to the S3 bucket."
  type        = map(string)
  default     = {}
}