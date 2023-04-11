
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = ["${module.module_vpc.my-vpc-project-subnet1_id}", "${module.module_vpc.my-vpc-project-subnet2_id}"]
}


# 데이터 베이스

# resource "aws_db_instance" "my-db" {
#   vpc_security_group_ids = [ "${module.module_vpc.my_db_sg_id}" ]
#   db_subnet_group_name   = aws_db_subnet_group.my_db_subnet_group.name
#   allocated_storage    = 20
#   identifier           = "mydb"
#   db_name              = "web"
#   engine               = "mysql"
#   engine_version       = "8.0.32"
#   instance_class       = "db.t3.micro"
#   username             = "admin"
#   password             = "qwer1234"
#   parameter_group_name = "default.mysql8.0"
#   publicly_accessible  = true
#   skip_final_snapshot  = true
#   multi_az = false
# }

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
  multi_az             = false
  backup_retention_period = 7 # 일주일 동안 백업 보존
}