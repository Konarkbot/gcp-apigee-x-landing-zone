resource "google_compute_network" "this" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode             = "GLOBAL"
  mtu                      = 1460
}

resource "google_compute_subnetwork" "this" {
  for_each                 = var.subnets
  project                  = var.project_id
  name                     = each.key
  region                   = var.region
  network                  = google_compute_network.this.id
  ip_cidr_range            = each.value.ip_cidr_range
  purpose                  = each.value.purpose
  private_ip_google_access = each.value.private_ip_google_access

  dynamic "log_config" {
    for_each = each.value.flow_logs && each.value.purpose == "PRIVATE" ? [1] : []
    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = 0.5
      metadata             = "INCLUDE_ALL_METADATA"
    }
  }

  role = try(each.value.role, null)

}

resource "google_compute_subnetwork" "proxy_only" {
  project       = var.project_id
  name          = "${var.network_name}-${var.region}-proxy-only"
  region        = var.region
  network       = google_compute_network.this.id
  ip_cidr_range = var.proxy_only_subnet_cidr
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

resource "google_compute_global_address" "apigee_range" {
  project       = var.project_id
  name          = "${var.network_name}-apigee-peering"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.apigee_peering_prefix_length
  network       = google_compute_network.this.id
}

resource "google_service_networking_connection" "apigee" {
  network                 = google_compute_network.this.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.apigee_range.name]
}

resource "google_compute_router" "this" {
  project = var.project_id
  name    = var.router_name
  region  = var.region
  network = google_compute_network.this.id

  bgp {
    asn            = var.router_asn
    advertise_mode = "DEFAULT"
  }
}

resource "google_compute_router_nat" "this" {
  project                            = var.project_id
  name                               = var.nat_name
  router                             = google_compute_router.this.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  dynamic "subnetwork" {
    for_each = var.nat_subnet_names
    content {
      name                    = google_compute_subnetwork.this[subnetwork.value].id
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_firewall" "allow_internal" {
  project = var.project_id
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.this.name

  direction = "INGRESS"
  priority  = 1000

  source_ranges = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  allow { protocol = "tcp" }
  allow { protocol = "udp" }
  allow { protocol = "icmp" }
}

