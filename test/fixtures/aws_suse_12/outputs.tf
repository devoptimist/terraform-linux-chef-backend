output "frontend_details" {
  value = module.chef_backend_cluster_suse_12.frontend_details
}
  
output "chef_frontend_base_url" {
  value = module.chef_backend_cluster_suse_12.chef_frontend_base_url
}
  
output "chef_server_org_url" {
  value = module.chef_backend_cluster_suse_12.chef_server_org_url
}
  
output "supermarket_uid" {
  value = module.chef_backend_cluster_suse_12.supermarket_uid
}
  
output "supermarket_secret" {
  value = module.chef_backend_cluster_suse_12.supermarket_secret
}
 
output "validation_pem" {
   value = module.chef_backend_cluster_suse_12.validation_pem
}
 
output "client_pem" {
  value = module.chef_backend_cluster_suse_12.client_pem
}

output "node_name" {
  value = module.chef_backend_cluster_suse_12.node_name
}
 
output "validation_client_name" {
  value = module.chef_backend_cluster_suse_12.validation_client_name
}

output "chef_servers_public_ip" {
  value = module.chef_backend_cluster_suse_12.chef_servers_public_ip
}

output "chef_servers_private_ip" {
  value = module.chef_backend_cluster_suse_12.chef_servers_private_ip
}

output "backend_servers_private_ip" {
  value = module.chef_backend_cluster_suse_12.backend_servers_private_ip
}

output "backend_servers_public_ip" {
  value = module.chef_backend_cluster_suse_12.backend_servers_public_ip
}
