variable "project_id" { type = string }
variable "authorized_network" { type = string }
variable "analytics_region" { type = string }
variable "org_display_name" { type = string default = "Apigee X Migration" }
variable "org_description" { type = string default = "Apigee X target platform for Apigee Edge migration." }
variable "billing_type" { type = string default = "PAYG" }
variable "runtime_type" { type = string default = "CLOUD" }
variable "instance_name" { type = string default = "apigee-runtime-01" }
variable "instance_region" { type = string }
variable "instance_cidr_range" { type = string default = "SLASH_22" }
variable "environments" {
  type = map(object({
    display_name = string
    description  = string
    type         = optional(string, "BASE")
    deployment_type = optional(string, "PROXY")
    api_proxy_type  = optional(string, "CONFIGURABLE")
    forward_proxy_uri = optional(string)
  }))
}
variable "environment_group" {
  type = object({
    name      = string
    hostnames = list(string)
  })
}
variable "enable" { type = bool default = true }
variable "deletion_policy" { type = string default = "PREVENT" }
