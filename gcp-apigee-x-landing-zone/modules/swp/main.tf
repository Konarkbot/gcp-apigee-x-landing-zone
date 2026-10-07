module "swp" {
  count   = var.enable ? 1 : 0
  source  = "GoogleCloudPlatform/secure-web-proxy/google"
  version = "0.4.6"

  gateway_name          = var.gateway_name
  project_id            = var.project_id
  region                = var.region
  network               = var.network
  subnetwork            = var.subnetwork
  certificate_urls      = var.certificate_urls
  certificate_config    = var.certificate_config
  next_hop_routing_mode = var.next_hop_routing_mode

  policy = {
    name        = var.policy_name
    description = var.policy_description
  }

  url_lists = length(var.allowed_domains) > 0 ? {
    allowed = {
      description = "Enterprise-approved outbound domains for the Apigee migration."
      values      = var.allowed_domains
    }
  } : {}

  rules = length(var.allowed_domains) > 0 ? {
    allow-approved-domains = {
      enabled         = true
      description     = "Allow only approved enterprise outbound domains."
      priority        = 100
      session_matcher = "inUrlList(host(), 'projects/${var.project_id}/locations/${var.region}/urlLists/allowed')"
      basic_profile   = "ALLOW"
    }
    deny-all = {
      enabled         = true
      description     = "Default deny rule."
      priority        = 1000
      session_matcher = "inIpRange(source.ip, '0.0.0.0/0')"
      basic_profile   = "DENY"
    }
  } : {
    deny-all = {
      enabled         = true
      description     = "Default deny rule until the security team provides an allow-list."
      priority        = 1000
      session_matcher = "inIpRange(source.ip, '0.0.0.0/0')"
      basic_profile   = "DENY"
    }
  }

  labels = var.labels
}
