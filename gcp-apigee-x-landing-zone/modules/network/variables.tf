variable "project_id" { type = string }
variable "network_name" { type = string }
variable "region" { type = string }
variable "subnets" {
  type = map(object({
    ip_cidr_range = string
    purpose       = optional(string, "PRIVATE")
    role          = optional(string)
    private_ip_google_access = optional(bool, true)
    flow_logs     = optional(bool, true)
  }))
}
variable "proxy_only_subnet_cidr" { type = string }
variable "apigee_peering_prefix_length" { type = number default = 16 }
variable "router_name" { type = string }
variable "router_asn" { type = number default = 64514 }
variable "nat_name" { type = string }
variable "nat_subnet_names" { type = set(string) }
variable "source_ranges_for_swp" { type = list(string) default = ["10.0.0.0/8"] }
variable "labels" { type = map(string) default = {} }
