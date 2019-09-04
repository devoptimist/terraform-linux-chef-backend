########### connection details ##################

variable "bootstrap_node_ip" {
  description = "IP address of the backedend node to bootstrap from"
  type        = string
}

variable "bootstrap_node_count" {
  description = "The number of bootstrap backend nodes being created, should only ever be 1"
  type        = number
  default     = 1
}

variable "backend_ips" {
  description = "A list of ip addresses where the chef backends will be installed"
  type        = list(string)
}

variable "backend_node_count" {
  description = "The number of chef backend instances being created, should only ever be 2"
  type        = number
  default     = 2
}

variable "frontend_ips" {
  description = "A list of ip addresses where the chef server will be installed"
  type        = list(string)
}

variable "frontend_node_count" {
  description = "The number of chef server instances being created"
  type        = number
  default     = 1
}

variable "ssh_user_name" {
  description = "The ssh user name used to access the ip addresses provided"
  type        = string
}

variable "ssh_user_pass" {
  description = "The ssh user password used to access the ip addresses (either ssh_user_pass or ssh_user_private_key needs to be set)"
  type        = string
  default     = ""
}

variable "ssh_user_private_key" {
  description = "The ssh user key used to access the ip addresses (either ssh_user_pass or ssh_user_private_key needs to be set)"
  type        = string
  default     = ""
}

variable "timeout" {
  description = "The timeout to wait for the connection to become available. Should be provided as a string like 30s or 5m. Defaults to 5 minutes."
  type        = string
  default     = "5m"
}

############ cookbook and run list data #########

variable "backend_cookbooks" {
  description = "the cookbooks used to deploy chef backend"
  default     = {
    "chef_backend_wrapper" = "github: 'devoptimist/chef_backend_wrapper', tag: 'v0.1.10'",
    "chef-ingredient"      = "github: 'chef-cookbooks/chef-ingredient', tag: 'v3.1.1'"
  }
}

variable "frontend_cookbooks" {
  description = "the cookbooks used to deploy chef server"
  default     = {
    "chef_server_wrapper" = "github: 'devoptimist/chef_server_wrapper', tag: 'v0.1.45'",
    "chef-ingredient"     = "github: 'chef-cookbooks/chef-ingredient', tag: 'v3.1.1'"
  }
}

variable "backend_runlist" {
  description = "The chef run list used to deploy chef backend"
  type        = list
  default     = ["chef_backend_wrapper::default"]
}

variable "frontend_runlist" {
  description = "The chef run list used to deploy chef server"
  type        = list
  default     = ["chef_server_wrapper::default"]
}

############ cluster secrets ####################

variable "postgresql_superuser_password" {
  description = "Password for the postgres superuser"
  type        = string
}

variable "postgresql_replication_password" {
  description = "Postgres replication user password"
  type        = string
}

variable "etcd_initial_cluster_token" {
  description = "etcd cluster token"
  type        = string
}

variable "elasticsearch_cluster_name" {
  description = "elasticsearch cluster name"
  type        = string
}

############ chef attributes ####################

variable "channel" {
  description = "The install channel to use for the chef server and backend package"
  type        = string
  default     = "stable"
}

variable "backend_install_version" {
  description = "The version of chef backend to install"
  type        = string
  default     = "2.0.30"
}

variable "frontend_install_version" {
  description = "The version of chef server to install"
  type        = string
  default     = "13.0.17"
}

variable "accept_license" {
  description = "Shall we accept the chef product license"
  default     = true
}

variable "extra_backend_config" {
  description = "Extra config to be passed to a chef server"
  type        = string
  default     = ""
}

variable "extra_frontend_config" {
  description = "Extra config to be passed to a chef backends"
  type        = string
  default     = ""
}

variable "peers" {
  description = "The private ip address of the bootstrapped backend node"
  type        = string
  default     = ""
}

variable "fqdn" {
  description = "no longer used"
  type        = string
  default     = ""
}

variable "frontend_config_dir" {
  description = "directory where the frontend configs are stored on the bootstrap node"
  type        = string
  default     = "/root/fe_confg"
}

variable "frontend_config_details" {
  description = "The location of the json file containing all the frontends config"
  type        = string
  default     = "/root/fe_confg/fe_details.json"
}

variable "frontend_parser_script" {
  description = "location of the script used to parse the frontend config"
  type        = string
  default     = "/bin/fe_parser"
}

variable "jq_url" {
  description = "A web location to pull the jq binary from, jq is used to prep data for the install"
  type        = string
  default     = "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
}

variable "data_collector_url" {
  description = "The url to a data collector (automate) end point"
  type        = list(string)
  default     = []
}

variable "data_collector_token" {
  description = "The token used to access the data collector end point"
  type        = list(string)
  default     = []
}

variable "frontend_addons" {
  description = "Any addons to be installed should be included in this map"
  type        = map
  default     = {}
}

variable "supermarket_url" {
  description = "Use this to configure the chef server to talk to a supermarket instance"
  type        = list(string)
  default     = []
}

variable "frontend_private_ips" {
  description = "List of the private ip's of each frontend server"
  type        = list(string)
}

variable "frontend_users" {
  description = "A map of users to be added to the chef server and their details"
  type        = map(object({ serveradmin=bool, first_name=string, last_name=string, email=string, password=string }))
  default     = {}
}

variable "frontend_orgs" {
  description = "A map of organisations to be added to the chef server"
  type        = map(object({ admins=list(string), org_full_name=string }))
  default     = {}
}

variable "frontend_fqdns" {
  description = "A list of fully qualified host names to apply to each chef server being created"
  type        = list(string)
  default     = []
}

variable "frontend_certs" {
  description = "A list of ssl certificates to apply to each chef server"
  type        = list(string)
  default     = []
}

variable "frontend_cert_keys" {
  description = "A list of ssl private keys to apply to each chef server"
  type        = list(string)
  default     = []
}

variable "force_frontend_chef_run" {
  description = "Set to anything other than default to force a rerun of provisioning on all chef frontends"
  type        = string
  default     = "default"
}
