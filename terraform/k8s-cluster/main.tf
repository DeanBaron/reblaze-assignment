terraform {
  required_version = ">= 0.12.0"
  backend "s3" {
    bucket = "reblaze-bucket"
    key    = "tfstate"
    region = "ap-southeast-2"
    dynamodb_table = "reblaze-lock-table"
  }

}

provider "aws" {
  region  = var.region
}

data "aws_availability_zones" "available" {
}

resource "aws_security_group" "all_worker_management" {
  name_prefix = var.security_group_name
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
      "172.16.0.0/12",
      "192.168.0.0/16",
    ]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name                 = "first-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  version = "18.21.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.21"
  subnet_ids = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_security_group_name = var.security_group_name

  vpc_id = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    disk_size      = 50
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }
}