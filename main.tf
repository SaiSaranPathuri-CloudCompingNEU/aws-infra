
module "networkingmy1" {
  source               = "./modules/networking"
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = var.availability_zones

}



# module "my_rds" {
#   app_security_group_id = module.myinstance.app_security_group_id

# }

module "myBucket" {
  source = "./modules/s3"

}

module "myinstance" {
  region              = var.region
  source              = "./modules/instance"
  ami_id              = var.ami_id
  key_pair            = var.key_pair
  vpc_id              = module.networkingmy1.vpc_id
  public_subnets_ids  = module.networkingmy1.public_subnets_ids
  private_subnets_ids = module.networkingmy1.private_subnets_ids
  database_username   = var.database_username
  database_password   = var.database_password
  database_name       = var.database_name
  ec2_iam_role        = module.myBucket.ec2_iam_role
  bucket_name         = module.myBucket.bucket_name

}


