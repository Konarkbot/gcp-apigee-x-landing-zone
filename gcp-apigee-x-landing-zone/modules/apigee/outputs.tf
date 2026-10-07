output "organization_id" { value = try(google_apigee_organization.this[0].id, null) }
output "instance_id" { value = try(google_apigee_instance.this[0].id, null) }
output "environments" { value = { for k, v in google_apigee_environment.this : k => v.name } }
output "environment_group_id" { value = try(google_apigee_envgroup.this[0].id, null) }
