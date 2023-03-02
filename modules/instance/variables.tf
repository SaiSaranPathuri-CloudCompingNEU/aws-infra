variable "ami_id" {
  description = "The ID of the custom AMI to use for the EC2 instance."
}
variable "region" {
  description = "The region used to launch this module resources."
}
variable "key_pair" {
  description = "The name of the EC2 key pair to use for SSH access to the EC2 instance."
}

variable "app_port" {
  description = "The port on which the web application runs."
  default     = 3000
}

variable "vpc_id" {
  description = "The ID of the VPC"
}

variable "public_subnets_ids" {
  type        = list(any)
  description = "The ID of the public subnet"
}

variable "private_subnets_ids" {
  type        = list(any)
  description = "The ID of the private subnet"
}

variable "database_username" {
  description = "The username of the database"
}

variable "database_password" {
  description = "The password of the database"
}
variable "database_name" {
  description = "The name of the database"
}
variable "ec2_iam_role" {
  description = "The name of the IAM role"
}
variable "bucket_name" {
  description = "The name of the S3 bucket"
}


