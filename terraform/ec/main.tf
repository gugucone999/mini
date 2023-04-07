# module "module_vpc" {
#   source = "../vpc"
# }

resource "aws_elasticache_subnet_group" "ec_subnet_group" {
  name       = "ec-subnet-group"
  subnet_ids = ["${module.module_vpc.my-vpc-project-subnet1_id}", "${module.module_vpc.my-vpc-project-subnet2_id}",
                "${module.module_vpc.my-vpc-project-subnet3_id}", "${module.module_vpc.my-vpc-project-subnet4_id}"]
}

resource "aws_elasticache_cluster" "ec_cluster" {
  cluster_id           = "ec-project"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.ec_subnet_group.name
  security_group_ids   = [ "${module.module_vpc.my_redis_sg_id}" ]
}




