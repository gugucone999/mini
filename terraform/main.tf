provider "aws" {
  region  = "ap-northeast-2"
}



module "module_project" {
  source = "./project"
  my_server_ami = "ami-0c6e5afdd23291f73"
  my_server_type = "t2.micro"
}

# module "module_rds" {
#   source = "./rds"
# }

# module "module_ec" {
#   source = "./ec"
# }

# module "module_vpc" {
#   source = "./vpc"
# }

