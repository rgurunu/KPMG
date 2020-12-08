variable "namespace" {
  type = string
}

variable "ssh_keypair" {
  type = string
}

variable "sg" {
  type = any
}

variable "vpc" {
  type = any
}

variable "subnet_public" {
  type = list(string)
}

variable "subnet_web" {
  type = list(string)
}

variable "subnet_app" {
  type = list(string)
}

variable "subnet_data" {
  type = list(string)
}

variable "certificate_arn" {
  default = "your_certificate_ARN"
}

variable "route53_hosted_zone_name" {
  default = "hosted_zone_domain"
}
