variable "tags" {
    type = map
    default = {
        Name = "my_crap_code"
        Project = "my_terraform"
        terraform = true
    }
}

variable "aws_region" {
  type = string
  default = "eu-north-1"
}

variable "vpc_cider_block" {
  type = string
  default = "10.0.0.0/16"
  
}

variable "vpc_cider_block_sub1" {
  type = string
  default = "10.0.1.0/24"
}

variable "vpc_cider_block_sub2" {
  type = string
  default = "10.0.2.0/24"

}

variable "vpc_security_group_ids" {
  type = string
  default = "aws_security_group.web.id"
}

variable "access_key" {
  type = string
  sensitive = true
}

variable "secret_key" {
  type = string
  sensitive = true
}
