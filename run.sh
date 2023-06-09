#!/bin/bash

terraform -chdir=project/terraform/ init

export TF_CLI_TIMEOUT=0

terraform -chdir=project/terraform/ apply -auto-approve -parallelism=10

# sudo aws elasticache describe-cache-clusters \
#  --cache-cluster-id ec-project \
#  --show-cache-node-info > /home/ubuntu/elasticache.json

 aws elasticache describe-replication-groups \
 --replication-group-id ec-replication-group > /home/ubuntu/elasticache.json

ansible-playbook -i project/ansible/aws_rds.yaml -i project/ansible/aws_ec2.yaml  project/ansible/playbook --user ubuntu
