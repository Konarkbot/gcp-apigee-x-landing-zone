variable "project_id" { type = string }
variable "log_bucket_name" { type = string default = "landing-zone-audit" }
variable "retention_days" { type = number default = 365 }
variable "enable" { type = bool default = true }
