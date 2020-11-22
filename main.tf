locals {

  consul_policyfile_name = "consul"
  chef_backend_policyfile_name = "chef_backend"
  chef_backend_fe_config_policyfile_name = "chef_backend_fe_config"

  consul_tmp_path = "${var.tmp_path}/${local.consul_policyfile_name}"
  consul_populate_script_lock_file = "${local.consul_tmp_path}/consul_populate.lock"
  data_script = var.frontend_config_details

  consul_populate_script = templatefile("${path.module}/templates/consul_populate_script", {
    data_script     = var.frontend_config_details
    consul_tmp_path = local.consul_tmp_path
    consul_port     = var.consul_port
    lock_file       = local.consul_populate_script_lock_file
  })

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
      "frontend_fqdns"          = var.frontend_private_ips,
      "frontend_config_dir"     = var.frontend_config_dir,
      "frontend_config_details" = var.frontend_config_details,
      "frontend_parser_script"  = var.frontend_parser_script,
      "backend_secrets"         = local.backend_secrets,
      "jq_url"                  = var.jq_url
    }
  }
}

module "backend_nodes_setup_0" {
  source           = "srb3/policyfile/chef"
  version          = "0.13.2"
  ip               = var.backend_ips[0]
  dna              = local.dna_bootstrap_node_setup
  cookbooks        = var.backend_cookbooks
  runlist          = var.backend_runlist
  user_name        = var.ssh_user_name
  user_pass        = var.ssh_user_pass
  user_private_key = var.ssh_user_private_key
  policyfile_name  = local.chef_backend_policyfile_name
}

module "backend_nodes_setup_1" {
  source           = "srb3/policyfile/chef"
  version          = "0.13.2"
  ip               = var.backend_ips[1]
  dna              = local.dna_backend_nodes_setup
  cookbooks        = var.backend_cookbooks
  runlist          = var.backend_runlist
  user_name        = var.ssh_user_name
  user_pass        = var.ssh_user_pass
  user_private_key = var.ssh_user_private_key
  policyfile_name  = local.chef_backend_policyfile_name
  depends_on       = [module.backend_nodes_setup_0]
}

module "backend_nodes_setup_2" {
  source           = "srb3/policyfile/chef"
  version          = "0.13.2"
  ip               = var.backend_ips[2]
  dna              = local.dna_backend_nodes_setup
  cookbooks        = var.backend_cookbooks
  runlist          = var.backend_runlist
  user_name        = var.ssh_user_name
  user_pass        = var.ssh_user_pass
  user_private_key = var.ssh_user_private_key
  policyfile_name  = local.chef_backend_policyfile_name
  depends_on       = [module.backend_nodes_setup_1]
}

module "bootstrap_frontend_config" {
  source           = "srb3/policyfile/chef"
  version          = "0.13.2"
  ip               = var.backend_ips[0]
  dna              = local.dna_frontend_details
  cookbooks        = var.backend_cookbooks
  runlist          = var.backend_runlist
  user_name        = var.ssh_user_name
  user_pass        = var.ssh_user_pass
  user_private_key = var.ssh_user_private_key
  policyfile_name  = local.chef_backend_fe_config_policyfile_name
  depends_on       = [module.backend_nodes_setup_2]
}

module "consul" {
  source                    = "srb3/consul/util"
  version                   = "0.13.4"
  ip                        = var.backend_ips[0]
  user_name                 = var.ssh_user_name
  user_private_key          = var.ssh_user_private_key
  populate_script           = local.consul_populate_script
  populate_script_lock_file = local.consul_populate_script_lock_file
  datacenter                = var.consul_datacenter
  linux_tmp_path            = var.tmp_path
  policyfile_name           = local.consul_policyfile_name
  port                      = var.consul_port
  log_level                 = var.consul_log_level
  depends_on                = [module.bootstrap_frontend_config]
}

data "http" "frontend_details" {
  url = "http://${var.backend_ips[0]}:${var.consul_port}/v1/kv/frontend-details?raw"
  request_headers = {
    Accept = "application/json"
  }
  depends_on = [module.consul]
}

locals {
  frontend_bootstrap_ip = length(var.frontend_ips) != 0 ? var.frontend_ips[0] : ""
}

module "frontend_bootstrap" {
  source               = "srb3/chef-server/linux"
  version              = "0.13.10"
  ip                   = local.frontend_bootstrap_ip
  config               = var.extra_frontend_config
  addons               = var.frontend_addons
  config_block         = jsondecode(data.http.frontend_details.body)
  data_collector_url   = var.data_collector_url
  data_collector_token = var.data_collector_token
  users                = var.frontend_users
  orgs                 = var.frontend_orgs
  supermarket_url      = var.supermarket_url
  fqdn                 = var.frontend_fqdn != "" ? var.frontend_fqdn : var.frontend_private_ips[0]
  cert                 = var.frontend_cert
  cert_key             = var.frontend_cert_key
  ssh_user_name        = var.ssh_user_name
  ssh_user_pass        = var.ssh_user_pass
  ssh_user_private_key = var.ssh_user_private_key
  depends_on           = [data.http.frontend_details]
}

locals {
  frontends = {
    for x in range(1, length(var.frontend_ips)):
      "frontends-${x}" => {
        "ip" = var.frontend_ips[x]
        "config" = var.extra_frontend_config,
        "addons" = var.frontend_addons,
        "config_block" = jsondecode(data.http.frontend_details.body),
        "data_collector_url" = var.data_collector_url,
        "data_collector_token" = var.data_collector_token,
        "supermarket_url" = var.supermarket_url,
        "fqdn" = var.frontend_fqdn != "" ? var.frontend_fqdn : var.frontend_private_ips[x]
        "cert" = var.frontend_cert,
        "cert_key" = var.frontend_cert_key,
        "ssh_user_name" = var.ssh_user_name,
        "ssh_user_pass" = var.ssh_user_pass,
        "ssh_user_private_key" = var.ssh_user_private_key,
        "frontend_secrets" = module.frontend_bootstrap.secret_output
      }
  }
}

module "frontend_create_all" {
  source               = "srb3/chef-server/linux"
  version              = "0.13.10"
  for_each             = local.frontends
  ip                   = each.value["ip"]
  config               = each.value["config"]
  addons               = each.value["addons"]
  config_block         = each.value["config_block"]
  data_collector_url   = each.value["data_collector_url"]
  data_collector_token = each.value["data_collector_token"]
  supermarket_url      = each.value["supermarket_url"]
  fqdn                 = each.value["fqdn"]
  cert                 = each.value["cert"]
  cert_key             = each.value["cert_key"]
  ssh_user_name        = each.value["ssh_user_name"]
  ssh_user_pass        = each.value["ssh_user_pass"]
  ssh_user_private_key = each.value["ssh_user_private_key"]
  frontend_secrets     = each.value["frontend_secrets"]
}
