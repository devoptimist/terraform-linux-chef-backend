output "frontend_details" {
  value = module.chef_backend_cluster.frontend_details
}
  
output "chef_frontend_base_url" {
  value = module.chef_backend_cluster.chef_frontend_base_url
}
  
output "chef_server_org_url" {
  value = module.chef_backend_cluster.chef_server_org_url
}
  
output "supermarket_uid" {
  value = module.chef_backend_cluster.supermarket_uid
}
  
output "supermarket_secret" {
  value = module.chef_backend_cluster.supermarket_secret
}
 
output "validation_pem" {
   value = module.chef_backend_cluster.validation_pem
}
 
output "client_pem" {
  value = module.chef_backend_cluster.client_pem
}

output "node_name" {
  value = module.chef_backend_cluster.node_name
}
 
output "validation_client_name" {
  value = module.chef_backend_cluster.validation_client_name
}

output "chef_servers_public_ip" {
  value = local.chef_servers_public_ip
}

output "chef_servers_private_ip" {
  value = local.chef_servers_private_ip
}

output "backend_servers_private_ip" {
  value = local.backend_servers_private_ip
}

output "backend_servers_public_ip" {
  value = local.backend_servers_public_ip
}
