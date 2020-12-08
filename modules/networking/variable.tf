variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  type = any 
  default = "10.20.0.0/16"
}

variable "public_subnets_cidr" {
  type = "list"
  default = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "web_subnets_cidr" {
  type = "list"
  default = ["10.20.11.0/24", "10.20.12.0/24"]
}

variable "app_subnets_cidr" {
  type = "list"
  default = ["10.20.21.0/24", "10.20.22.0/24"]
}

variable "data_subnets_cidr" {
  type = "list"
  default = ["10.20.31.0/24", "10.20.32.0/24"]
}

variable "azs" {
  type = "list"
  default = ["us-east-1a", "us-east-1b"]
}
