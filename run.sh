#!/bin/bash

terraform -chdir=/3tier/terraform/ apply -auto-approve
ansible-playbook -i /3tier/ansible/aws_rds.yaml -i /3tier/ansible/aws_ec2.yaml  /3tier/ansible/playbook --user ubuntu
