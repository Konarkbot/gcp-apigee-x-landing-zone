variable "project_id" { type = string }
variable "services" { type = set(string) }
variable "disable_on_destroy" { type = bool default = false }
variable "labels" { type = map(string) default = {} }
