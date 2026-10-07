output "gateway_id" { value = try(module.swp[0].gateway_id, null) }
output "gateway_ip_addresses" { value = try(module.swp[0].gateway_ip_addresses, []) }
output "policy_id" { value = try(module.swp[0].policy_id, null) }
output "self_link" { value = try(module.swp[0].self_link, null) }
output "service_attachment_id" { value = try(module.swp[0].service_attachment_id, null) }
