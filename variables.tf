########### connection details ##################

variable "bootstrap_node_ip" {
  type    = string
}

variable "bootstrap_node_count" {
  default = 1
}

variable "backend_ips" {
  type    = list(string)
}

variable "backend_node_count" {
  default = 2
}

variable "frontend_ips" {
  type    = list(string)
}

variable "frontend_node_count" {
  default = 1
}

variable "ssh_user_name" {
  type    = string
  default = "chefuser"
}

variable "ssh_user_pass" {
  type    = string
  default = "P@55w0rd1"
}

variable "ssh_user_private_key" {
  type    = string
  default = ""
}

############ cookbook and run list data #########

variable "backend_cookbooks" {
  default = {
    "chef_backend_wrapper" = "github: 'devoptimist/chef_backend_wrapper', tag: 'v0.1.10'",
    "chef-ingredient" = "github: 'chef-cookbooks/chef-ingredient', tag: 'v3.1.1'"
  }
}

variable "frontend_cookbooks" {
  default = {
    "chef_server_wrapper" = "github: 'devoptimist/chef_server_wrapper', tag: 'v0.1.45'",
    "chef-ingredient" = "github: 'chef-cookbooks/chef-ingredient', tag: 'v3.1.1'"
  }
}

variable "backend_runlist" {
  type    = list
  default = ["chef_backend_wrapper::default"]
}

variable "frontend_runlist" {
  type    = list
  default = ["chef_server_wrapper::default"]
}
############ cluster secrets ####################

variable "postgresql_superuser_password" {
  type = string
}

variable "postgresql_replication_password" {
  type = string
}

variable "etcd_initial_cluster_token" {
  type = string
}

variable "elasticsearch_cluster_name" {
  type = string
}

############ chef attributes ####################

variable "channel" {
  type    = string
  default = "stable"
}

variable "backend_install_version" {
  type    = string
  default = "2.0.30"
}

variable "frontend_install_version" {
  type    = string
  default = "12.19.31"
}

variable "accept_license" {
  default = true
}

variable "extra_backend_config" {
  type    = string
  default = ""
}

variable "extra_frontend_config" {
  type    = string
  default = ""
}

variable "peers" {
  type    = string
  default = ""
}

variable "fqdn" {
  type    = string
  default = ""
}

variable "frontend_config_dir" {
  type    = string
  default = "/root/fe_confg"
}

variable "frontend_config_details" {
  type    = string
  default = "/root/fe_confg/fe_details.json"
}

variable "frontend_parser_script" {
  type    = string
  default = "/bin/fe_parser"
}

variable "jq_url" {
  type    = string
  default = "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
}

variable "data_collector_url" {
  type    = list(string)
  default = []
}

variable "data_collector_token" {
  type    = list(string)
  default = []
}

variable "frontend_addons" {
  type    = map
  default = {}
}

variable "supermarket_url" {
  type    = list(string)
  default = []
}

variable "frontend_private_ips" {
  type    = list(string)
}

variable "frontend_users" {
  type    = map(object({ serveradmin=bool, first_name=string, last_name=string, email=string, password=string }))
  default = {}
}

variable "frontend_orgs" {
  type    = map(object({ admins=list(string), org_full_name=string }))
  default = {}
}

variable "frontend_fqdns" {
  type    = list(string)
  default = []
}

variable "frontend_certs" {
  type    = list(string)
  default = []
}

variable "frontend_cert_keys" {
  type    = list(string)
  default = []
}

variable "force_frontend_chef_run" {
  type    = string
  default = "default"
}
