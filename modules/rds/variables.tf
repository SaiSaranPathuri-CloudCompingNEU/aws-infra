variable "vpc_id" {
  description = "The ID of the VPC"
}

variable "private_subnets" {
  type        = list(any)
  description = "The ID of the private subnet"
}

variable "database_username" {
  description = "The username of the database"
}

variable "database_password" {
  description = "The password of the database"
}


variable "database_port" {
  description = "The port of the database"
}

# Path: modules/rds/main.tf


