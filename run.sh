#!/bin/bash

terraform -chdir=/3tier/terraform/ apply -auto-approve

sudo aws elasticache describe-cache-clusters \
 --cache-cluster-id ec-project \
 --show-cache-node-info > elasticache.json

ansible-playbook -i /3tier/ansible/aws_rds.yaml -i /3tier/ansible/aws_ec2.yaml  /3tier/ansible/playbook --user ubuntu
