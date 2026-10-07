variable "project_id" { type = string }
variable "region" { type = string default = "us-central1" }
variable "analytics_region" { type = string default = "us-central1" }
variable "labels" { type = map(string) default = {} }

variable "network_name" { type = string default = "apigee-lz-nonprod" }
variable "app_subnet_cidr" { type = string default = "10.20.0.0/20" }
variable "swp_subnet_cidr" { type = string default = "10.20.16.0/24" }
variable "proxy_only_subnet_cidr" { type = string default = "10.20.20.0/23" }
variable "apigee_peering_prefix_length" { type = number default = 16 }
variable "router_name" { type = string default = "apigee-lz-router" }
variable "router_asn" { type = number default = 64514 }
variable "nat_name" { type = string default = "apigee-lz-nat" }
variable "swp_client_source_ranges" { type = list(string) default = ["10.20.0.0/20"] }

variable "enable_swp" { type = bool default = true }
variable "swp_gateway_name" { type = string default = "apigee-swp-nonprod" }
variable "swp_policy_name" { type = string default = "apigee-swp-policy" }
variable "swp_allowed_domains" { type = list(string) default = [] }
variable "swp_certificate_urls" { type = list(string) default = [] }
variable "swp_certificate_config" {
  type = any
  default = {
    create_self_signed = {
      dns_names = ["swp-nonprod.example.internal"]
      subject = {
        common_name = "swp-nonprod.example.internal"
        organization = "Apigee Migration NonProd"
      }
    }
  }
}
variable "swp_next_hop_routing_mode" { type = bool default = false }

variable "enable_security_foundation" { type = bool default = true }
variable "kms_key_ring_name" { type = string default = "apigee-lz" }
variable "kms_crypto_key_name" { type = string default = "landing-zone-secrets" }
variable "bootstrap_secret_names" { type = set(string) default = [] }

variable "enable_observability" { type = bool default = true }
variable "audit_log_bucket_name" { type = string default = "apigee-lz-audit" }
variable "audit_log_retention_days" { type = number default = 365 }

variable "enable_apigee" { type = bool default = true }
variable "apigee_billing_type" { type = string default = "PAYG" }
variable "apigee_org_display_name" { type = string default = "Apigee X NonProd" }
variable "apigee_org_description" { type = string default = "Apigee X non-production organization for Edge migration." }
variable "apigee_instance_name" { type = string default = "apigee-nonprod-01" }
variable "apigee_instance_region" { type = string default = "us-central1" }
variable "apigee_instance_cidr_range" { type = string default = "SLASH_22" }
variable "apigee_environments" {
  type = map(object({
    display_name = string
    description = string
    type = optional(string, "BASE")
    deployment_type = optional(string, "PROXY")
    api_proxy_type = optional(string, "CONFIGURABLE")
  }))
  default = {
    dev = {
      display_name = "Development"
      description = "Apigee X development environment."
    }
    test = {
      display_name = "Test"
      description = "Apigee X test environment."
    }
  }
}
variable "apigee_environment_group" {
  type = object({ name = string, hostnames = list(string) })
  default = {
    name = "nonprod"
    hostnames = ["api-nonprod.example.com"]
  }
}

variable "enable_private_dns_zone" { type = bool default = false }
variable "private_dns_zone_name" { type = string default = "apigee-private" }
variable "private_dns_domain" { type = string default = "nonprod.example.internal." }
