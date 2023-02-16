/*
we define AWS keys and region
*/
provider "aws" {
  region  = var.region
  profile =  var.profile
}