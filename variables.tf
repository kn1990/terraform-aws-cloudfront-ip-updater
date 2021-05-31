variable "name" {
  description = "Name for resources"
  type        = string
  default     = "Cloudfront-IP-Updater"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "To configure the Region for the SDK client used in the Lambda function. If the CloudFront origin is present in a different Region than N. Virginia, the security groups must be created in that region."
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "To create security groups in a specific VPC"
  type        = string
}

variable "ports" {
  description = "To create security groups rules for a different port or multiple ports. The solution in this example supports a total of two ports. One can be used for HTTP and another for HTTPS."
  type        = string
  default     = "80,443"
}

variable "debug" {
  description = "To enable debug logging to CloudWatch"
  type        = bool
  default     = true
}

variable "prefix_name" {
  description = "To customize the prefix name tag of your security groups"
  type        = string
  default     = "AUTOUPDATE"
}

variable "service" {
  description = "To extract IP ranges for a different service other than CloudFront"
  type        = string
  default     = "CLOUDFRONT"
}
