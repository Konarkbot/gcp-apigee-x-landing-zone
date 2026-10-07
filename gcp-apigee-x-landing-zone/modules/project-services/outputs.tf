output "enabled_services" { value = sort([for s in google_project_service.services : s.service]) }
