terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-west-2"
}

variable "credentials_profile" {
  description = "The AWS credentials profile to use"
  type        = string
  default     = "saml"
}

provider "aws" {
  region  = var.region
  profile = var.credentials_profile
}

# Create network
resource "aws_vpc" "terraform_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "A-HA-testing-vpc"
  }
}

resource "aws_subnet" "terraform_public_subnet" {
  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "A-HA-testing-public-subnet"
  }
}

resource "aws_route_table_association" "rtb_association" {
  subnet_id      = aws_subnet.terraform_public_subnet.id
  route_table_id = aws_vpc.terraform_vpc.main_route_table_id
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.terraform_vpc.id
  tags = {
    Name = "A-HA-testing-igw"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_vpc.terraform_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

locals {
  sg_ingress_rules = {
    "ssh" = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    },
    "http" = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    },
    "https" = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    },
  }
}

resource "aws_vpc_security_group_ingress_rule" "terraform_sg_ingress" {
  for_each          = local.sg_ingress_rules
  security_group_id = aws_vpc.terraform_vpc.default_security_group_id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.ip_protocol
  cidr_ipv4         = each.value.cidr_ipv4
}

resource "terraform_data" "local-exec" {
  provisioner "local-exec" {
    command = <<EOT
      sed -i '' 's/region: .*/region: ${var.region}/' kitchen.ec2.yml
      sed -i '' 's/subnet_id: .*/subnet_id: ${aws_subnet.terraform_public_subnet.id}/' kitchen.ec2.yml
      sed -i '' 's/security_group_ids: .*/security_group_ids: ${aws_vpc.terraform_vpc.default_security_group_id}/' kitchen.ec2.yml
      sed -i '' 's/shared_credentials_profile: .*/shared_credentials_profile: ${var.credentials_profile}/' kitchen.ec2.yml
    EOT
  }
}
