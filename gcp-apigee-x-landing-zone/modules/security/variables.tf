variable "project_id" { type = string }
variable "region" { type = string }
variable "key_ring_name" { type = string default = "landing-zone" }
variable "crypto_key_name" { type = string default = "terraform-secrets" }
variable "secret_names" { type = set(string) default = [] }
variable "enable" { type = bool default = true }
