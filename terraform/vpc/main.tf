resource "aws_vpc" "my-vpc-project" {
  cidr_block = "200.200.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc-project"
  }
}

resource "aws_subnet" "my-vpc-project-subnet1" {
  vpc_id = aws_vpc.my-vpc-project.id
  cidr_block = "200.200.10.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "my-vpc-project-subnet1"
  }
}

resource "aws_subnet" "my-vpc-project-subnet2" {
  vpc_id = aws_vpc.my-vpc-project.id
  cidr_block = "200.200.20.0/24"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "my-vpc-project-subnet2"
  }
}

resource "aws_subnet" "my-vpc-project-subnet3" {
  vpc_id = aws_vpc.my-vpc-project.id
  cidr_block = "200.200.30.0/24"
  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "my-vpc-project-subnet3"
  }
}

resource "aws_subnet" "my-vpc-project-subnet4" {
  vpc_id = aws_vpc.my-vpc-project.id
  cidr_block = "200.200.40.0/24"
  availability_zone = "ap-northeast-2d"
  map_public_ip_on_launch = true
  tags = {
    Name = "my-vpc-project-subnet4"
  }
}

resource "aws_internet_gateway" "my-igw-project" {
  vpc_id = aws_vpc.my-vpc-project.id
}

resource "aws_default_route_table" "my-vpc-project-route-table" {
  default_route_table_id = aws_vpc.my-vpc-project.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw-project.id
  }
}

resource "aws_security_group" "my_django_sg" {
  vpc_id = aws_vpc.my-vpc-project.id
  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "my_redis_sg" {
  vpc_id = aws_vpc.my-vpc-project.id
  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "redis"
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "my_db_sg" {
  vpc_id = aws_vpc.my-vpc-project.id
  ingress {
    description = "mysql"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# output "my-vpc-project_name" {
#   value = aws_security_group.my-vpc-project.name
# }





output "my_django_sg_id" {
  value = aws_security_group.my_django_sg.id
}

output "my_redis_sg_id" {
  value = aws_security_group.my_redis_sg.id
}

output "my-vpc-project_id" {
  value = aws_vpc.my-vpc-project.id
}

output "my-vpc-project-subnet1_id" {
  value = aws_subnet.my-vpc-project-subnet1.id
}

output "my-vpc-project-subnet2_id" {
  value = aws_subnet.my-vpc-project-subnet2.id
}

output "my-vpc-project-subnet3_id" {
  value = aws_subnet.my-vpc-project-subnet3.id
}

output "my-vpc-project-subnet4_id" {
  value = aws_subnet.my-vpc-project-subnet4.id
}

output "my_db_sg_id" {
  value = aws_security_group.my_db_sg.id
}
