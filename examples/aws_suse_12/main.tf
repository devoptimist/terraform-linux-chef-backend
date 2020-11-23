provider "aws" {
  shared_credentials_file = var.aws_creds_file
  profile                 = var.aws_profile
  region                  = var.aws_region
}

data "aws_availability_zones" "available" {}

module "ami" {
  source  = "srb3/ami/aws"
  version = "0.13.0"
  os_name = "suse-12"
}

resource "random_id" "hash" {
  byte_length = 4
}

locals {
  azs = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1]
  ]

  sg_data = {
    "backend" = {
      "ingress_with_cidr_blocks" = var.ingress_with_cidr_blocks,
      "ingress_rules"            = var.backend_ingress_rules,
      "ingress_cidr"             = concat(var.backend_ingress_cidrs, var.public_subnets),
      "egress_rules"             = var.backend_egress_rules,
      "egress_cidr"              = concat(var.backend_egress_cidrs, var.public_subnets),
      "description"              = "backend security group"
      "vpc_id"                   = module.vpc.vpc_id
    },
    "chef" = {
      "ingress_with_cidr_blocks" = [],
      "ingress_rules"            = var.chef_server_ingress_rules,
      "ingress_cidr"             = concat(var.chef_server_ingress_cidrs, var.public_subnets),
      "egress_rules"             = var.chef_server_egress_rules,
      "egress_cidr"              = concat(var.chef_server_egress_cidrs, var.public_subnets),
      "description"              = "chef security group"
      "vpc_id"                   = module.vpc.vpc_id
    }
  }

  backend_vm_data = {
    for x in range(0, 3) :
    "backend-${x}" => {
      "ami"                = module.ami.id,
      "instance_type"      = var.backend_instance_type,
      "key_name"           = var.aws_key_name,
      "security_group_ids" = [module.security_group["backend"].id],
      "subnet_ids"         = module.vpc.public_subnets,
      "root_block_device"  = [{ volume_type = "gp2", volume_size = "40" }],
      "public_ip_address"  = true
    }
  }

  chef_vm_data = {
    for x in range(0, var.number_of_chef_servers) :
    "chef-${x}" => {
      "ami"                = module.ami.id,
      "instance_type"      = var.chef_server_instance_type,
      "key_name"           = var.aws_key_name,
      "security_group_ids" = [module.security_group["chef"].id],
      "subnet_ids"         = module.vpc.public_subnets,
      "root_block_device"  = [{ volume_type = "gp2", volume_size = "40" }],
      "public_ip_address"  = true
    }
  }

  vm_data = merge(local.backend_vm_data, local.chef_vm_data)
}

module "vpc" {
  source         = "srb3/vpc/aws"
  version        = "0.13.0"
  name           = "Automate and Squid vpc"
  cidr           = "10.0.0.0/16"
  azs            = local.azs
  public_subnets = var.public_subnets
  tags           = var.tags
}

module "security_group" {
  source                   = "srb3/security-group/aws"
  version                  = "0.13.1"
  for_each                 = local.sg_data
  name                     = each.key
  description              = each.value["description"]
  vpc_id                   = each.value["vpc_id"]
  ingress_with_cidr_blocks = each.value["ingress_with_cidr_blocks"]
  ingress_rules            = each.value["ingress_rules"]
  ingress_cidr_blocks      = each.value["ingress_cidr"]
  egress_rules             = each.value["egress_rules"]
  egress_cidr_blocks       = each.value["egress_cidr"]
  tags                     = var.tags
}

module "instance" {
  source                      = "srb3/vm/aws"
  version                     = "0.13.2"
  for_each                    = local.vm_data
  name                        = each.key
  ami                         = each.value["ami"]
  instance_type               = each.value["instance_type"]
  key_name                    = each.value["key_name"]
  security_group_ids          = each.value["security_group_ids"]
  subnet_ids                  = each.value["subnet_ids"]
  root_block_device           = each.value["root_block_device"]
  associate_public_ip_address = each.value["public_ip_address"]
  get_password_data           = lookup(each.value, "get_password_data", false)
  tags                        = var.tags
}

locals {
  backend_servers_public_ip = [
    for x in range(0, 3) :
    module.instance["backend-${x}"].public_ip[0]
  ]

  backend_servers_private_ip = [
    for x in range(0, 3) :
    module.instance["backend-${x}"].private_ip[0]
  ]

  backend_peer_ip = module.instance["backend-0"].private_ip[0]

  chef_servers_public_ip = [
    for x in range(0, var.number_of_chef_servers) :
    module.instance["chef-${x}"].public_ip[0]
  ]

  chef_servers_private_ip = [
    for x in range(0, var.number_of_chef_servers) :
    module.instance["chef-${x}"].private_ip[0]
  ]

  addons = var.chef_server_addons

}

module "chef_backend_cluster" {
  source                          = "../../"
  peers                           = local.backend_peer_ip
  backend_ips                     = local.backend_servers_public_ip
  frontend_ips                    = local.chef_servers_public_ip
  frontend_private_ips            = local.chef_servers_private_ip
  ssh_user_name                   = module.ami.user
  ssh_user_private_key            = var.ssh_user_private_key
  frontend_users                  = var.chef_server_users
  frontend_orgs                   = var.chef_server_orgs
  frontend_addons                 = local.addons
  postgresql_superuser_password   = var.postgresql_superuser_password
  postgresql_replication_password = var.postgresql_replication_password
  etcd_initial_cluster_token      = var.etcd_initial_cluster_token
  elasticsearch_cluster_name      = var.elasticsearch_cluster_name
  frontend_install_version        = var.frontend_install_version
  backend_install_version         = var.backend_install_version
}
