variable "vpc_cidr" {
  description = "CIDR for the whole VPC"

}

variable "availability_zones" {
  type        = list(any)
  description = "The az that the resources will be launched"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}

