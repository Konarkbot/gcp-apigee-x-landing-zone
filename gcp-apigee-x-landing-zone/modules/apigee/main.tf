resource "google_apigee_organization" "this" {
  count            = var.enable ? 1 : 0
  project_id       = var.project_id
  display_name     = var.org_display_name
  description      = var.org_description
  analytics_region = var.analytics_region
  billing_type     = var.billing_type
  runtime_type     = var.runtime_type
  authorized_network = var.authorized_network
}

resource "google_apigee_instance" "this" {
  count            = var.enable ? 1 : 0
  name             = var.instance_name
  location         = var.instance_region
  org_id           = google_apigee_organization.this[0].id
  peering_cidr_range = var.instance_cidr_range
  deletion_policy  = var.deletion_policy
  depends_on       = [google_apigee_organization.this]
}

resource "google_apigee_environment" "this" {
  for_each = var.enable ? var.environments : {}
  org_id   = google_apigee_organization.this[0].id
  name         = each.key
  display_name = each.value.display_name
  description  = each.value.description
  type         = each.value.type
  deployment_type = each.value.deployment_type
  api_proxy_type  = each.value.api_proxy_type
  forward_proxy_uri = try(each.value.forward_proxy_uri, null)
  deletion_policy = var.deletion_policy
  depends_on = [google_apigee_instance.this]
}

resource "google_apigee_instance_attachment" "this" {
  for_each    = var.enable ? var.environments : {}
  instance_id = google_apigee_instance.this[0].id
  environment = google_apigee_environment.this[each.key].name
  deletion_policy = var.deletion_policy
  depends_on = [google_apigee_environment.this]
}

resource "google_apigee_envgroup" "this" {
  count      = var.enable ? 1 : 0
  name       = var.environment_group.name
  hostnames  = var.environment_group.hostnames
  org_id     = google_apigee_organization.this[0].id
  deletion_policy = var.deletion_policy
  depends_on = [google_apigee_environment.this]
}
