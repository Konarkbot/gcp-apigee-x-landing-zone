output "network_id" { value = google_compute_network.this.id }
output "network_self_link" { value = google_compute_network.this.self_link }
output "subnets" { value = { for k, v in google_compute_subnetwork.this : k => v.self_link } }
output "proxy_only_subnet" { value = google_compute_subnetwork.proxy_only.self_link }
output "apigee_peering_range" { value = google_compute_global_address.apigee_range.name }
output "service_networking_connection" { value = google_service_networking_connection.apigee.id }
output "router_name" { value = google_compute_router.this.name }
output "nat_name" { value = google_compute_router_nat.this.name }
