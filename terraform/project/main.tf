module "module_vpc" {
  source = "../vpc"
}

resource "aws_instance" "Redis_check" {
  count                   = 1
  ami           = var.my_server_ami
  instance_type = var.my_server_type

  vpc_security_group_ids = [ "${module.module_vpc.my_django_sg_id}" ]
  subnet_id = "${module.module_vpc.my-vpc-project-subnet1_id}"
  key_name = "project"

  tags = {
    Name  = "redis-check-${count.index}"
    group = "redis"
  }
}


resource "aws_instance" "my_django" {
  count                   = 2
  ami                     = var.my_server_ami
  instance_type           = var.my_server_type
  vpc_security_group_ids  = [ "${module.module_vpc.my_django_sg_id}" ]
  subnet_id               = element([module.module_vpc.my-vpc-project-subnet1_id,
                                     module.module_vpc.my-vpc-project-subnet3_id,
                                    ], count.index)
  key_name                = "project"
  # subnet_id               = "${module.module_vpc.my-vpc-project-subnet1_id}"

  tags = {
    Name  = "my-django-${count.index}"
    group = "django"
  }
}

resource "aws_lb" "django" {
  name     = "my-lb"
  security_groups = [ "${module.module_vpc.my_django_sg_id}" ]
  load_balancer_type = "application"
  subnets  = ["${module.module_vpc.my-vpc-project-subnet1_id}", "${module.module_vpc.my-vpc-project-subnet2_id}",
              "${module.module_vpc.my-vpc-project-subnet3_id}", "${module.module_vpc.my-vpc-project-subnet4_id}"]
  internal = false

  tags = {
    Name = "my-lb"
  }
}

resource "aws_lb_target_group" "django" {
  name     = "my-lb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${module.module_vpc.my-vpc-project_id}"

  health_check {
    interval            = 30
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
     Name = "django Target Group" 
    }
}

resource "aws_lb_listener" "django" {
  load_balancer_arn = aws_lb.django.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.django.arn
  }
}

resource "aws_lb_target_group_attachment" "django" {
  count = 5
  target_group_arn = aws_lb_target_group.django.arn
  target_id        = element(aws_instance.my_django.*.id, count.index)
  port             = 80
}

resource "aws_elasticache_subnet_group" "ec_subnet_group" {
  name       = "ec-subnet-group"
  subnet_ids = ["${module.module_vpc.my-vpc-project-subnet1_id}", "${module.module_vpc.my-vpc-project-subnet2_id}",
                "${module.module_vpc.my-vpc-project-subnet3_id}", "${module.module_vpc.my-vpc-project-subnet4_id}"]
}

# 단일 ec 만들때 사용!

# resource "aws_elasticache_cluster" "ec_cluster" {
#   cluster_id           = "ec-project"
#   engine               = "redis"
#   node_type            = "cache.t2.micro"
#   num_cache_nodes      = 1
#   parameter_group_name = "default.redis7"
#   engine_version       = "7.0"
#   port                 = 6379
#   subnet_group_name    = aws_elasticache_subnet_group.ec_subnet_group.name
#   security_group_ids   = [ "${module.module_vpc.my_redis_sg_id}" ]
# }

resource "aws_elasticache_replication_group" "ec_replication_group" {
  replication_group_id       =  "ec-replication-group"
  description = "ElastiCache Redis Replication Group"
  node_type                  = "cache.t2.micro"
  num_cache_clusters         = 2
  automatic_failover_enabled = true
  subnet_group_name          = aws_elasticache_subnet_group.ec_subnet_group.name
  parameter_group_name       = "default.redis7"
  port                       = 6379
  security_group_ids         =  [ "${module.module_vpc.my_redis_sg_id}" ]
  engine_version             = "7.0"
  engine                     = "redis"
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = ["${module.module_vpc.my-vpc-project-subnet1_id}", "${module.module_vpc.my-vpc-project-subnet2_id}"]
}

resource "aws_db_instance" "my-master" {
  vpc_security_group_ids = [ "${module.module_vpc.my_db_sg_id}" ]
  db_subnet_group_name   = aws_db_subnet_group.my_db_subnet_group.name
  allocated_storage    = 20
  identifier           = "mydb"
  db_name              = "web"
  engine               = "mysql"
  engine_version       = "8.0.32"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "qwer1234"
  parameter_group_name = "default.mysql8.0"
  publicly_accessible  = true
  skip_final_snapshot  = true
  multi_az = false
  backup_retention_period = 7
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

# resource "aws_db_instance" "my-read-replica" {
#   count                   = 1
#   vpc_security_group_ids = [ "${module.module_vpc.my_db_sg_id}" ]
#   replicate_source_db = aws_db_instance.my-master.identifier
#   instance_class       = "db.t3.micro"
#   publicly_accessible  = true
#   skip_final_snapshot  = true
#   multi_az = false
#   backup_retention_period = 7
#   tags = {
#     Name  = "mydb-read-replica-${count.index}"
#   }
#   timeouts {
#     create = "30m"
#     update = "30m"
#     delete = "30m"
#   }
# }
