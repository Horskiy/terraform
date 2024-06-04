variable "tags" {
    type = map
    default = {
        Name = "my_crap_code"
        Project = "my_terraform"
        terraform = true
    }
}

variable "vpc_cider_block" {
  type = string
}

variable "public_subnet_cidr_blocks" {
  type        = list(any)
  description = "List of public subnet CIDR blocks"
}

variable "private_subnet_cidr_blocks" {
  type        = list(any)
  description = "List of public subnet CIDR blocks"
}

variable "region" {
    type = string
    description = "Region of the VPC"
  
}

variable "access_key" {
  type = string
  sensitive = true
}

variable "secret_key" {
  type = string
  sensitive = true
}

variable "azs" {
    type = list(any)
    description = "List aviability zone"
}

variable "internal" {
  type = bool
}

variable "load_balancer_type" {
  description = "Load balancer type"
  type        = string

}

variable "alb_subnets" {
  description = "A list of subnet IDs to use for the resources."
  type        = list(string)
}

variable "load_balancing_algorithm" {
  description = "Specify the load balancing algorithm type"
  type        = string
}

variable "listener_port" {
  description = "Listener port"
  type        = number
}

variable "listener_protocol" {
  description = "Listener protocol"
  type        = string
}

variable "listener_type" {
  description = "Listener type"
  type        = string
}
variable "health_check_path" {
  description = "Health check path"
  type        = string
}

variable "health_check_port" {
  description = "Health check port"
  type        = number
}

variable "health_check_protocol" {
  description = "Health check protocol"
  type        = string
}

variable "health_check_interval" {
  description = "Health check interval"
  type        = number
}

variable "health_check_timeout" {
  description = "Health check timeout"
  type        = number
}

variable "health_check_healthy_threshold" {
  description = "Health check healthy threshold"
  type        = number
}

variable "health_check_unhealthy_threshold" {
  description = "Health check unhealthy threshold"
  type        = number
}
