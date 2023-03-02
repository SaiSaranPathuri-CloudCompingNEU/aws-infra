profile  = "dev"         //AWS profile
region   = "us-east-1"   //AWS region
vpc_cidr = "10.1.0.0/16" //VPC cidr range

public_subnets_cidr  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
private_subnets_cidr = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]

# ami_id   = "ami-045a2c6d9bd7a0d9d"  //AMI ID
ami_id   = "ami-057b04caf82a5984f"
key_pair = "test" //Key pair name

database_name     = "csye6225"
database_username = "csye6225"
database_password = "Saicharan"
