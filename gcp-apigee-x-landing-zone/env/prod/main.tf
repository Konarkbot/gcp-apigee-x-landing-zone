locals {
  common_labels = merge(var.labels, {
    managed_by = "terraform"
    platform   = "apigee-x"
    migration  = "edge-to-apigee-x"
    environment = "prod"
  })

  required_services = toset([
    "serviceusage.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "apigee.googleapis.com",
    "apigeeconnect.googleapis.com",
    "networkservices.googleapis.com",
    "networksecurity.googleapis.com",
    "dns.googleapis.com",
    "certificatemanager.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "cloudkms.googleapis.com",
    "secretmanager.googleapis.com",
    "securitycenter.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
  ])
}

module "services" {
  source     = "../../modules/project-services"
  project_id = var.project_id
  services   = local.required_services
}

module "network" {
  source     = "../../modules/network"
  project_id = var.project_id
  network_name = var.network_name
  region = var.region
  router_name = var.router_name
  router_asn  = var.router_asn
  nat_name    = var.nat_name
  nat_subnet_names = ["app-${var.region}", "swp-${var.region}"]
  proxy_only_subnet_cidr = var.proxy_only_subnet_cidr
  apigee_peering_prefix_length = var.apigee_peering_prefix_length
  source_ranges_for_swp = var.swp_client_source_ranges

  subnets = {
    "app-${var.region}" = {
      ip_cidr_range = var.app_subnet_cidr
      purpose       = "PRIVATE"
      private_ip_google_access = true
      flow_logs = true
    }
    "swp-${var.region}" = {
      ip_cidr_range = var.swp_subnet_cidr
      purpose       = "PRIVATE"
      private_ip_google_access = true
      flow_logs = true
    }
  }

  labels = local.common_labels
  depends_on = [module.services]
}

module "swp" {
  source = "../../modules/swp"
  project_id = var.project_id
  region = var.region
  network = module.network.network_self_link
  subnetwork = module.network.subnets["swp-${var.region}"]
  gateway_name = var.swp_gateway_name
  policy_name = var.swp_policy_name
  allowed_domains = var.swp_allowed_domains
  certificate_urls = var.swp_certificate_urls
  certificate_config = var.swp_certificate_config
  next_hop_routing_mode = var.swp_next_hop_routing_mode
  labels = local.common_labels
  enable = var.enable_swp
  depends_on = [module.network]
}

module "security" {
  source = "../../modules/security"
  project_id = var.project_id
  region = var.region
  key_ring_name = var.kms_key_ring_name
  crypto_key_name = var.kms_crypto_key_name
  secret_names = var.bootstrap_secret_names
  enable = var.enable_security_foundation
  depends_on = [module.services]
}

module "observability" {
  source = "../../modules/observability"
  project_id = var.project_id
  log_bucket_name = var.audit_log_bucket_name
  retention_days = var.audit_log_retention_days
  enable = var.enable_observability
  depends_on = [module.services]
}

module "apigee" {
  source = "../../modules/apigee"
  project_id = var.project_id
  authorized_network = module.network.network_self_link
  analytics_region = var.analytics_region
  org_display_name = var.apigee_org_display_name
  org_description = var.apigee_org_description
  billing_type = var.apigee_billing_type
  runtime_type = "CLOUD"
  instance_name = var.apigee_instance_name
  instance_region = var.apigee_instance_region
  instance_cidr_range = var.apigee_instance_cidr_range
  environments = var.apigee_environments
  environment_group = var.apigee_environment_group
  enable = var.enable_apigee
  deletion_policy = "PREVENT"
  depends_on = [module.network, module.services]
}

resource "google_dns_managed_zone" "private" {
  count       = var.enable_private_dns_zone ? 1 : 0
  project     = var.project_id
  name        = var.private_dns_zone_name
  dns_name    = var.private_dns_domain
  description = "Private DNS zone for Apigee X migration landing zone."

  visibility = "private"
  private_visibility_config {
    networks { network_url = module.network.network_self_link }
  }
  depends_on = [module.network]
}
