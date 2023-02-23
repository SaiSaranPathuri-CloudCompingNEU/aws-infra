/*
we call our modules here
*/
module "mynetwork-1" {
  /*
    mention the folder where your module is
    */
  source = "./module/networking"
  /*
    then mention all the variables that you'll be using in this module
    */
  cidr                   = var.cidr
  igw_cidr               = var.igw_cidr
  private_cidrs          = var.private_cidrs
  public_cidrs           = var.public_cidrs
  aws_availability_zones = var.aws_availability_zones

}
