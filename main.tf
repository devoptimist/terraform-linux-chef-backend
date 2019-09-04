locals {
  backend_secrets = templatefile("${path.module}/templates/backend_secrets.json", {
    postgresql_superuser_password   = var.postgresql_superuser_password,
    postgresql_replication_password = var.postgresql_replication_password,
    etcd_initial_cluster_token      = var.etcd_initial_cluster_token,
    elasticsearch_cluster_name      = var.elasticsearch_cluster_name
  })

  dna_bootstrap_node_setup = {
    "chef_backend_wrapper" = {
      "channel"                 = var.channel,
      "version"                 = var.backend_install_version,
      "accept_license"          = var.accept_license,
      "config"                  = var.extra_backend_config,
      "peers"                   = "",
      "fqdn"                    = var.fqdn,
      "frontend_fqdns"          = [],
      "frontend_config_dir"     = var.frontend_config_dir,
      "frontend_config_details" = var.frontend_config_details,
      "frontend_parser_script"  = var.frontend_parser_script,
      "backend_secrets"         = local.backend_secrets,
      "jq_url"                  = var.jq_url
    }
  }

  dna_backend_nodes_setup = {
    "chef_backend_wrapper" = {
      "channel"                 = var.channel,
      "version"                 = var.backend_install_version,
      "accept_license"          = var.accept_license,
      "config"                  = var.extra_backend_config,
      "peers"                   = var.peers,
      "fqdn"                    = var.fqdn,
      "frontend_fqdns"          = [],
      "frontend_config_dir"     = var.frontend_config_dir,
      "frontend_config_details" = var.frontend_config_details,
      "frontend_parser_script"  = var.frontend_parser_script,
      "backend_secrets"         = local.backend_secrets,
      "jq_url"                  = var.jq_url
    }
  }

  dna_frontend_details = {
    "chef_backend_wrapper" = {
      "channel"                 = var.channel,
      "version"                 = var.backend_install_version,
      "accept_license"          = var.accept_license,
      "config"                  = var.extra_backend_config,
      "peers"                   = "",
      "fqdn"                    = var.fqdn,
      "frontend_fqdns"          = length(var.frontend_fqdns) != 0 ? var.frontend_fqdns : var.frontend_private_ips,
      "frontend_config_dir"     = var.frontend_config_dir,
      "frontend_config_details" = var.frontend_config_details,
      "frontend_parser_script"  = var.frontend_parser_script,
      "backend_secrets"         = local.backend_secrets,
      "jq_url"                  = var.jq_url
    }
  }
  module_inputs = [
    for ip in var.backend_ips :
    {
      "chef_backend_wrapper" = {
      }
    }
  ]
}

module "bootstrap_node_setup" {
  source           = "devoptimist/policyfile/chef"
  version          = "0.0.7"
  ips              = [var.bootstrap_node_ip]
  instance_count   = 1
  dna              = [local.dna_bootstrap_node_setup]
  module_inputs    = local.module_inputs
  cookbooks        = var.backend_cookbooks
  runlist          = var.backend_runlist
  user_name        = var.ssh_user_name
  user_pass        = var.ssh_user_pass
  user_private_key = var.ssh_user_private_key
  timeout          = var.timeout
}

module "backend_nodes_setup_0" {
  source           = "devoptimist/policyfile/chef"
  version          = "0.0.7"
  ips              = [var.backend_ips[0]]
  instance_count   = 1
  dna              = [local.dna_backend_nodes_setup]
  module_inputs    = local.module_inputs
  cookbooks        = var.backend_cookbooks
  runlist          = var.backend_runlist
  hook_data        = jsonencode(module.bootstrap_node_setup.module_hook)
  user_name        = var.ssh_user_name
  user_pass        = var.ssh_user_pass
  user_private_key = var.ssh_user_private_key
  timeout          = var.timeout
}

module "backend_nodes_setup_1" {
  source           = "devoptimist/policyfile/chef"
  version          = "0.0.7"
  ips              = [var.backend_ips[1]]
  instance_count   = 1
  dna              = [local.dna_backend_nodes_setup]
  module_inputs    = local.module_inputs
  cookbooks        = var.backend_cookbooks
  runlist          = var.backend_runlist
  hook_data        = jsonencode(module.backend_nodes_setup_0.module_hook)
  user_name        = var.ssh_user_name
  user_pass        = var.ssh_user_pass
  user_private_key = var.ssh_user_private_key
  timeout          = var.timeout
}

module "bootstrap_frontend_config" {
  source           = "devoptimist/policyfile/chef"
  version          = "0.0.7"
  ips              = [var.bootstrap_node_ip]
  instance_count   = 1
  dna              = [local.dna_frontend_details]
  module_inputs    = local.module_inputs
  cookbooks        = var.backend_cookbooks
  runlist          = var.backend_runlist
  hook_data        = jsonencode(module.backend_nodes_setup_1.module_hook)
  user_name        = var.ssh_user_name
  user_pass        = var.ssh_user_pass
  user_private_key = var.ssh_user_private_key
  timeout          = var.timeout
}

data "external" "chef_frontend_details" {
  program = ["bash", "${path.module}/files/data_source.sh"]

  query = {
    ssh_user          = var.ssh_user_name
    ssh_pass          = var.ssh_user_pass
    ssh_key           = var.ssh_user_private_key
    bootstrap_node_ip = var.bootstrap_node_ip
    fe_details        = var.frontend_config_details
  }

  depends_on = ["module.bootstrap_frontend_config"]
}

module "frontend_bootstrap" {
  source               = "devoptimist/chef-server/linux"
  version              = "0.0.6"
  ips                  = length(var.frontend_ips) != 0 ? slice(var.frontend_ips, 0, 1) : []
  instance_count       = 1
  config               = var.extra_frontend_config
  addons               = var.frontend_addons
  config_block         = data.external.chef_frontend_details.result
  data_collector_url   = [ for i in var.frontend_ips : length(var.data_collector_url) != 0 ? element(var.data_collector_url, 0) : "" ]
  data_collector_token = [ for i in var.frontend_ips : length(var.data_collector_token) != 0 ? element(var.data_collector_token, 0) : "" ]
  users                = var.frontend_users
  orgs                 = var.frontend_orgs
  supermarket_url      = [ for i in var.frontend_ips : length(var.supermarket_url) != 0 ? index(var.frontend_ips, i) == 0 ?  element(var.supermarket_url, 0) : "" : "" ]
  fqdns                = length(var.frontend_fqdns) != 0 ? var.frontend_fqdns : var.frontend_private_ips
  certs                = var.frontend_certs 
  cert_keys            = var.frontend_cert_keys
  ssh_user_name        = var.ssh_user_name
  ssh_user_pass        = var.ssh_user_pass
  ssh_user_private_key = var.ssh_user_private_key
  force_run            = var.force_frontend_chef_run
  timeout              = var.timeout
}

module "frontend_create_all" {
  source               = "devoptimist/chef-server/linux"
  version              = "0.0.6"
  ips                  = length(var.frontend_ips) > 1 ? slice(var.frontend_ips, 1, length(var.frontend_ips)) : []
  instance_count       = var.frontend_node_count - 1
  config               = var.extra_frontend_config
  addons               = var.frontend_addons
  config_block         = data.external.chef_frontend_details.result
  data_collector_url   = slice([ for i in var.frontend_ips : length(var.data_collector_url) != 0 ? element(var.data_collector_url, 0) : "" ], 1, length(var.frontend_ips))
  data_collector_token = slice([ for i in var.frontend_ips : length(var.data_collector_token) != 0 ? element(var.data_collector_token, 0) : "" ], 1, length(var.frontend_ips))
  supermarket_url      = slice([ for i in var.frontend_ips : length(var.supermarket_url) != 0 ? index(var.frontend_ips, i) == 0 ?  element(var.supermarket_url, 0) : "" : "" ], 1, length(var.frontend_ips))
  fqdns                = length(var.frontend_fqdns) != 0 ? slice(var.frontend_fqdns, 1, length(var.frontend_ips)) : slice(var.frontend_private_ips, 1, length(var.frontend_private_ips))
  certs                = var.frontend_certs
  cert_keys            = var.frontend_cert_keys
  ssh_user_name        = var.ssh_user_name
  ssh_user_pass        = var.ssh_user_pass
  ssh_user_private_key = var.ssh_user_private_key
  frontend_secrets     = module.frontend_bootstrap.secret_output
  force_run            = var.force_frontend_chef_run
  timeout              = var.timeout
}
