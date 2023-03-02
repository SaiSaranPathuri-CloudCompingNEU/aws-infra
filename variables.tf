variable "region" {
  description = "The region used to launch this module resources."
}
variable "profile" {
  description = "The profile name as set in the shared credentials file. If not set, it will be sourced from the AWS_PROFILE environment variable."
}

//Networking module variables
variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}
variable "availability_zones" {
  type        = list(any)
  description = "The az that the resources will be launched"
}

#instance module variables
variable "ami_id" {
  description = "The ID of the custom AMI to use for the EC2 instance."
}

variable "key_pair" {
  description = "The name of the EC2 key pair to use for SSH access to the EC2 instance."
}
variable "database_username" {
  description = "The username of the database"
  default     = "csye6225"
}

variable "database_password" {
  description = "The password of the database"
  default     = "Saicharan"
}

variable "database_name" {
  description = "The name of the database"
  default     = "CSYEWebapp"
}