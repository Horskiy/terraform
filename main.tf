terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  default_tags {
      tags = merge(var.tags, {Environment = "Dev"})
    }
}

data "aws_availability_zones" "working" {}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cider_block
  
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_subnet" "private_subnets" {
  count      = length(var.private_subnet_cidr_blocks)
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.private_subnet_cidr_blocks[count.index]

  tags = {
    Name = "My_privet_subnet"
  }
}

resource "aws_subnet" "public_subnets" {
  count      = length(var.public_subnet_cidr_blocks)
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.public_subnet_cidr_blocks[count.index]

  tags = {
    Name = "My_public_subnet"
  }
}
