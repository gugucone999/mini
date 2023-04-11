module "module_vpc" {
  source = "../vpc"
}

module "module_rds" {
  source = "../rds"
}

module "module_ec" {
  source = "../elasticache"
}


# resource "aws_instance" "my_play" {
#   ami           = var.my_server_ami
#   instance_type = var.my_server_type

#   vpc_security_group_ids = [ "${module.module_vpc.my_django_sg_id}" ]
#   subnet_id = "${module.module_vpc.my-vpc-project-subnet1_id}"
#   key_name = "project"

#   tags = {
#     group = "play"
#   }
# }

resource "aws_instance" "my_django" {
  count                   = 1
  ami                     = var.my_server_ami
  instance_type           = var.my_server_type
  vpc_security_group_ids  = [ "${module.module_vpc.my_django_sg_id}" ]
  subnet_id               = element([module.module_vpc.my-vpc-project-subnet1_id,
                                     module.module_vpc.my-vpc-project-subnet3_id,
                                    ], count.index)
  key_name                = "project"
  # subnet_id               = "${module.module_vpc.my-vpc-project-subnet1_id}"

  tags = {
    Name  = "my_django-${count.index}"
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



