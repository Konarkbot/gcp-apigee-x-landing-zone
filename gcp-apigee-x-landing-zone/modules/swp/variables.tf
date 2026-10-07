variable "project_id" { type = string }
variable "region" { type = string }
variable "network" { type = string }
variable "subnetwork" { type = string }
variable "gateway_name" { type = string }
variable "policy_name" { type = string }
variable "policy_description" { type = string default = "Controlled egress policy for Apigee migration workloads." }
variable "allowed_domains" { type = list(string) default = [] }
variable "certificate_urls" { type = list(string) default = [] }
variable "certificate_config" { type = any default = null }
variable "next_hop_routing_mode" { type = bool default = false }
variable "labels" { type = map(string) default = {} }
variable "enable" { type = bool default = true }
