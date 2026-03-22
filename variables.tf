variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "my_ip_cidr" {
  description = "CIDR block for my IP"
  type        = string
  default     = "89.247.164.252/32"
}

variable "region" {
  description = "The region where the resources are created."
  default     = "ap-southeast-1"
}

variable "prefix" {
  description = "This prefix will be included in the name of most resources."
}

variable "environment" {
  default     = "Production"
  description = "target environment"
}

variable "instance_type" {
  description = "Specifies the AWS instance type."
  default     = "t2.micro"
}
