########### connection details ##################

variable "backend_ips" {
  description = "A list of ip addresses where the chef backends will be installed"
  type        = list(string)
}

variable "frontend_ips" {
  description = "A list of ip addresses where the chef server will be installed"
  type        = list(string)
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
    "chef_backend_wrapper" = "github: 'srb3/chef_backend_wrapper', tag: 'v0.1.11'",
    "chef-ingredient"      = "github: 'chef-cookbooks/chef-ingredient', tag: 'v3.2.0'"
  }
}

variable "frontend_cookbooks" {
  description = "the cookbooks used to deploy chef server"
  default     = {
    "chef_server_wrapper" = "github: 'srb3/chef_server_wrapper', tag: 'v0.1.50'",
    "chef-ingredient"     = "github: 'chef-cookbooks/chef-ingredient', tag: 'v3.2.0'"
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
  default     = "2.2.0"
}

variable "frontend_install_version" {
  description = "The version of chef server to install"
  type        = string
  default     = "14.0.65"
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
  type        = string
  default     = ""
}

variable "data_collector_token" {
  description = "The token used to access the data collector end point"
  type        = string
  default     = ""
}

variable "frontend_addons" {
  description = "Any addons to be installed should be included in this map"
  type        = map
  default     = {}
}

variable "supermarket_url" {
  description = "The URL to a supermarket instance"
  type        = string
  default     = ""
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

variable "frontend_fqdn" {
  description = "A fully qualified host names to apply to each chef server being created"
  type        = string
  default     = ""
}

variable "frontend_cert" {
  description = "An ssl certificates to apply to each chef server"
  type        = string
  default     = ""
}

variable "frontend_cert_key" {
  description = "An ssl private keys to apply to each chef server"
  type        = string
  default     = ""
}

############ consul settings #####################

variable "consul_datacenter" {
  description = "The name of the datacenter to use for consul"
  type        = string
  default     = "dc1"
}

variable "consul_port" {
  description = "The port number to use for consul"
  type        = string
  default     = "8500"
}

variable "consul_log_level" {
  description = "The log level to run the consul service as"
  type        = string
  default     = "info"
}

variable "tmp_path" {
  description = "The path to a tempory directory to stage the backend cluster and consul install"
  type        = string
  default     = "/var/tmp"
}
