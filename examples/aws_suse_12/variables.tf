########### AWS settings #########################

variable "aws_creds_file" {
  description = "The path to an aws credentials file"
  type        = string
}

variable "aws_profile" {
  description = "The name of an aws profile to use"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "The aws region to use"
  type        = string
  default     = "eu-west-1"
}

variable "tags" {
  description = "A set of tags to assign to the instances created by this module"
  type        = map(string)
  default     = {}
}

########### base vm settings #####################

variable "aws_key_name" {
  description = "The name of an aws key pair to use for chef automate"
  type        = string
}

########### backend server config ################

variable "backend_install_version" {
  description = "The version of chef backend to install"
  type        = string
  default     = "2.0.30"
}

########### backend security settings ###########

variable "backend_ingress_rules" {
  description = "Rules for traffic comming into chef backend"
  type        = list(string)
  default     = ["consul-webui-tcp", "ssh-tcp"]
}

variable "backend_egress_rules" {
  description = "Rules for traffic leaving chef automate"
  type        = list(string)
  default     = ["all-all"]
}

variable "backend_ingress_cidrs" {
  description = "A list of CIDR's to use for allowing access to the automate vm"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "backend_egress_cidrs" {
  description = "A list of CIDR's to use for allowing access out from chef autoamte"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ingress_with_cidr_blocks" {
  description = "A list of maps of security settings for the backend servers"
  type        = list(map(string))
  default = [
    {
      "from_port"   = 2379
      "to_port"     = 2380
      "protocol"    = "tcp"
      "description" = "etcd"
      "cidr_blocks" = "10.0.1.0/24"
    },
    {
      "from_port"   = 5432
      "to_port"     = 5432
      "protocol"    = "tcp"
      "description" = "postgresql"
      "cidr_blocks" = "10.0.1.0/24"
    },
    {
      "from_port"   = 7331
      "to_port"     = 7331
      "protocol"    = "tcp"
      "description" = "leaderl"
      "cidr_blocks" = "10.0.1.0/24"
    },
    {
      "from_port"   = 9200
      "to_port"     = 9400
      "protocol"    = "tcp"
      "description" = "leaderl"
      "cidr_blocks" = "10.0.1.0/24"
    }
  ]
}

variable "public_subnets" {
  description = "A list of public subnets to create"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

########### chef_server security settings ##############

variable "chef_server_ingress_rules" {
  description = "Rules for traffic comming into the chef_server proxy"
  type        = list(string)
  default     = ["consul-webui-tcp", "ssh-tcp", "http-80-tcp", "https-443-tcp"]
}

variable "chef_server_egress_rules" {
  description = "Rules for traffic leaving the chef_server proxy"
  type        = list(string)
  default     = ["all-all"]
}

variable "chef_server_ingress_cidrs" {
  description = "A list of CIDR's to use for allowing access to the chef_server vm"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "chef_server_egress_cidrs" {
  description = "A list of CIDR's to use for allowing access out from the chef_server proxy"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

########### backend vm settings #################

variable "backend_instance_type" {
  description = "The name of the instance type to use for chef automate"
  type        = string
  default     = "t3.large"
}

########### chef_server vm settings ####################

variable "number_of_chef_servers" {
  description = "The number of chef servers to deploy"
  type        = number
  default     = 1
}

variable "chef_server_instance_type" {
  description = "The name of the instance type to use for chef chef_server"
  type        = string
  default     = "t3.large"
}

############ chef_server install settings ###########

variable "ssh_user_private_key" {
  description = "The ssh private key used to access the chef servers and backend server"
  type        = string
}

########## chef server config ###################

variable "chef_server_addons" {
  type    = map
  default = {}
}

variable "frontend_install_version" {
  type    = string
  default = "13.1.13"
}

variable "chef_server_hostname" {
  description = "not used"
  type        = string
  default     = ""
}

variable "chef_server_users" {
  type    = map(object({ serveradmin = bool, first_name = string, last_name = string, email = string, password = string }))
  default = {}
}

variable "chef_server_orgs" {
  type    = map(object({ admins = list(string), org_full_name = string }))
  default = {}
}

variable "chef_frontend_config" {
  type    = string
  default = ""
}

variable "chef_server_ssl_cert" {
  type    = string
  default = ""
}

variable "chef_server_ssl_key" {
  type    = string
  default = ""
}

########### backend cluster secrets ##############

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
