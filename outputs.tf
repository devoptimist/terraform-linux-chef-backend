output "my_output" {
  value = data.external.chef_frontend_details.result
}

output "chef_frontend_base_url" {
  value = module.frontend_bootstrap.base_url
}

output "chef_server_org_url" {
  value = module.frontend_bootstrap.org_url
}

output "supermarket_uid" {
  value = module.frontend_bootstrap.supermarket_uid
}

output "supermarket_secret" {
  value = module.frontend_bootstrap.supermarket_secret
}
