variable "region" {
  type    = string
  default = "us-east-2"
}
variable "profile" {
  type    = string
  default = "dev"
  default = "demo"
}

variable "cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "igw_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "public_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "aws_availability_zones" {
  type    = list(string)
  default = ["us-east-2a", "us-east-2b", "us-east-2c"]
}
