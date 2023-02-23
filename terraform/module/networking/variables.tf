variable "cidr" {
  type = string
  #default = "10.10.0.0/16"
}

variable "igw_cidr" {
  type = string
  #default = "0.0.0.0/0"
}

variable "public_cidrs" {
  type = list(string)
  #default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_cidrs" {
  type = list(string)
  #default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}


variable "aws_availability_zones" {
  type = list(string)
  #default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "ami" {
  type    = string
  default = "ami-0acfa6d36b89d5dcb"
}

variable "key_name" {
  type    = string
  default = "ec2_dev"
}

variable "ssh_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFoJMCuNdwdCE4WNpBjWyljoQ9+Qr+JxfnHnZ/emuKZQTRSWHfKa+sEmZy9OG1xGoEVbzjb00UogzOQTnlFxd/s6odlQzaBRlCbpPKhrG7q6pdWrXosu21HDMbqgW4Tg73v+rTmiSis3Yh5ZN+s/xu/1lNQ5OYdSM/PFx7lcZ3HkVd9SX24HX322MsZPuvvPNs4/xAD30Z7OK+ymAxQ+ZZKWL9Sv4TDthVatFoNYEgnF4wWSuHvf2ZmE8EId36/fs/DumrCcJJxq2yT/FatkDF2XQeA/gR1MOYGvOjGMRnDdez3B4xtUoJmZD6AWquHcNbIYN/YGA8whymqN/WwfnQWepY0zURoxb9HRTl70ddNho72Gurzw13Ph9FLxY+PwnZnxxo/AO/E8j56Ddhl2RnzH8H0xGSZcFG59hWMzjAuq7R1ljd3zEfqFTrWRE5F1iwKLHddhGPcaxn1zupkLvIINnLQRnDp1Px5ONJpY4n0/e5nqIR+rYTOn7fWEZeLp8= saisaranpathuri@Sais-MacBook-Air-2.local"
}


