output "frontend_details" {
  value = jsondecode(data.http.frontend_details.body)
}

output "chef_frontend_base_url" {
  value = module.frontend_bootstrap.base_url
}

output "chef_server_org_url" {
  value = module.frontend_bootstrap.org_url
}

output "chef_server" {
  value = module.frontend_bootstrap
}

output "supermarket_uid" {
  value = module.frontend_bootstrap.supermarket_uid
}

output "supermarket_secret" {
  value = module.frontend_bootstrap.supermarket_secret
}

output "validation_pem" {
  value = module.frontend_bootstrap.validation_pem
}

output "client_pem" {
  value = module.frontend_bootstrap.client_pem
}

output "node_name" {
  value = module.frontend_bootstrap.node_name
}

output "validation_client_name" {
  value = module.frontend_bootstrap.validation_client_name
}
