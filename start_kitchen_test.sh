#!/usr/bin/env bash
##############################################
#
# Automate HA Test setup
# Run from local workstation
#
##############################################

# Stop on error
set -e

platform="${1:-almalinux-8}"

# Bring up kitchen nodes
echo "**** Starting kitchen create $platform ****"
kitchen create $platform -c 3

echo "**** Writing IP's of machines to kitchen_nodes.json ****"
if [[ "$KITCHEN_LOCAL_YAML" == "kitchen.ec2.yml" ]]
  then
    chef_frontend_1="$(aws --profile saml ec2 describe-instances --instance-ids $(cat .kitchen/chef-frontend-1-$platform.yml | grep server_id | cut -d ' ' -f 2) --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
    automate_frontend_1="$(aws --profile saml ec2 describe-instances --instance-ids $(cat .kitchen/automate-frontend-1-$platform.yml | grep server_id | cut -d ' ' -f 2) --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
    postgres_backend_1="$(aws --profile saml ec2 describe-instances --instance-ids $(cat .kitchen/postgres-backend-1-$platform.yml | grep server_id | cut -d ' ' -f 2) --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
    postgres_backend_2="$(aws --profile saml ec2 describe-instances --instance-ids $(cat .kitchen/postgres-backend-2-$platform.yml | grep server_id | cut -d ' ' -f 2) --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
    postgres_backend_3="$(aws --profile saml ec2 describe-instances --instance-ids $(cat .kitchen/postgres-backend-3-$platform.yml | grep server_id | cut -d ' ' -f 2) --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
    opensearch_backend_1="$(aws --profile saml ec2 describe-instances --instance-ids $(cat .kitchen/opensearch-backend-1-$platform.yml | grep server_id | cut -d ' ' -f 2) --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
    opensearch_backend_2="$(aws --profile saml ec2 describe-instances --instance-ids $(cat .kitchen/opensearch-backend-2-$platform.yml | grep server_id | cut -d ' ' -f 2) --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
    opensearch_backend_3="$(aws --profile saml ec2 describe-instances --instance-ids $(cat .kitchen/opensearch-backend-3-$platform.yml | grep server_id | cut -d ' ' -f 2) --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
    bastion="$(aws --profile saml ec2 describe-instances --instance-ids $(cat .kitchen/bastion-$platform.yml | grep server_id | cut -d ' ' -f 2) --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
elif [[ "$KITCHEN_LOCAL_YAML" == "kitchen.dokken.yml" ]]
  then
    # Get external IPs
    chef_frontend_1="$(docker network inspect dokken -f '{{json .Containers}}' | jq '.[] | .Name + ":" + .IPv4Address' | grep chef-frontend-1-$platform | cut -d ':' -f2 | cut -d '/' -f1)"
    automate_frontend_1="$(docker network inspect dokken -f '{{json .Containers}}' | jq '.[] | .Name + ":" + .IPv4Address' | grep automate-frontend-1-$platform | cut -d ':' -f2 | cut -d '/' -f1)"
    postgres_backend_1="$(docker network inspect dokken -f '{{json .Containers}}' | jq '.[] | .Name + ":" + .IPv4Address' | grep postgres-backend-1-$platform | cut -d ':' -f2 | cut -d '/' -f1)"
    postgres_backend_2="$(docker network inspect dokken -f '{{json .Containers}}' | jq '.[] | .Name + ":" + .IPv4Address' | grep postgres-backend-2-$platform | cut -d ':' -f2 | cut -d '/' -f1)"
    postgres_backend_3="$(docker network inspect dokken -f '{{json .Containers}}' | jq '.[] | .Name + ":" + .IPv4Address' | grep postgres-backend-3-$platform | cut -d ':' -f2 | cut -d '/' -f1)"
    opensearch_backend_1="$(docker network inspect dokken -f '{{json .Containers}}' | jq '.[] | .Name + ":" + .IPv4Address' | grep opensearch-backend-1-$platform | cut -d ':' -f2 | cut -d '/' -f1)"
    opensearch_backend_2="$(docker network inspect dokken -f '{{json .Containers}}' | jq '.[] | .Name + ":" + .IPv4Address' | grep opensearch-backend-2-$platform | cut -d ':' -f2 | cut -d '/' -f1)"
    opensearch_backend_3="$(docker network inspect dokken -f '{{json .Containers}}' | jq '.[] | .Name + ":" + .IPv4Address' | grep opensearch-backend-3-$platform | cut -d ':' -f2 | cut -d '/' -f1)"
    bastion="$(docker network inspect dokken -f '{{json .Containers}}' | jq '.[] | .Name + ":" + .IPv4Address' | grep bastion-$platform | cut -d ':' -f2 | cut -d '/' -f1)"
elif [[ "$VAGRANT_DEFAULT_PROVIDER" == "parallels" ]]
  then
    # Get external IPs
    chef_frontend_1="$(prlctl exec $(cat .kitchen/kitchen-vagrant/chef-frontend-1-$platform/.vagrant/machines/default/parallels/id) ip -o -f inet address show eth0 | cut -d ' ' -f7 | cut -d '/' -f1)"
    automate_frontend_1="$(prlctl exec $(cat .kitchen/kitchen-vagrant/automate-frontend-1-$platform/.vagrant/machines/default/parallels/id) ip -o -f inet address show eth0 | cut -d ' ' -f7 | cut -d '/' -f1)"
    postgres_backend_1="$(prlctl exec $(cat .kitchen/kitchen-vagrant/postgres-backend-1-$platform/.vagrant/machines/default/parallels/id) ip -o -f inet address show eth0 | cut -d ' ' -f7 | cut -d '/' -f1)"
    postgres_backend_2="$(prlctl exec $(cat .kitchen/kitchen-vagrant/postgres-backend-2-$platform/.vagrant/machines/default/parallels/id) ip -o -f inet address show eth0 | cut -d ' ' -f7 | cut -d '/' -f1)"
    postgres_backend_3="$(prlctl exec $(cat .kitchen/kitchen-vagrant/postgres-backend-3-$platform/.vagrant/machines/default/parallels/id) ip -o -f inet address show eth0 | cut -d ' ' -f7 | cut -d '/' -f1)"
    opensearch_backend_1="$(prlctl exec $(cat .kitchen/kitchen-vagrant/opensearch-backend-1-$platform/.vagrant/machines/default/parallels/id) ip -o -f inet address show eth0 | cut -d ' ' -f7 | cut -d '/' -f1)"
    opensearch_backend_2="$(prlctl exec $(cat .kitchen/kitchen-vagrant/opensearch-backend-2-$platform/.vagrant/machines/default/parallels/id) ip -o -f inet address show eth0 | cut -d ' ' -f7 | cut -d '/' -f1)"
    opensearch_backend_3="$(prlctl exec $(cat .kitchen/kitchen-vagrant/opensearch-backend-3-$platform/.vagrant/machines/default/parallels/id) ip -o -f inet address show eth0 | cut -d ' ' -f7 | cut -d '/' -f1)"
    bastion="$(prlctl exec $(cat .kitchen/kitchen-vagrant/bastion-$platform/.vagrant/machines/default/parallels/id) ip -o -f inet address show eth0 | cut -d ' ' -f7 | cut -d '/' -f1)"
else
  # Get external IPs
  chef_frontend_1="$(VBoxManage guestproperty get $(cat .kitchen/kitchen-vagrant/chef-frontend-1-$platform/.vagrant/machines/default/virtualbox/id) "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{print $2}')"
  automate_frontend_1="$(VBoxManage guestproperty get $(cat .kitchen/kitchen-vagrant/automate-frontend-1-$platform/.vagrant/machines/default/virtualbox/id) "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{print $2}')"
  postgres_backend_1="$(VBoxManage guestproperty get $(cat .kitchen/kitchen-vagrant/postgres-backend-1-$platform/.vagrant/machines/default/virtualbox/id) "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{print $2}')"
  postgres_backend_2="$(VBoxManage guestproperty get $(cat .kitchen/kitchen-vagrant/postgres-backend-2-$platform/.vagrant/machines/default/virtualbox/id) "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{print $2}')"
  postgres_backend_3="$(VBoxManage guestproperty get $(cat .kitchen/kitchen-vagrant/postgres-backend-3-$platform/.vagrant/machines/default/virtualbox/id) "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{print $2}')"
  opensearch_backend_1="$(VBoxManage guestproperty get $(cat .kitchen/kitchen-vagrant/opensearch-backend-1-$platform/.vagrant/machines/default/virtualbox/id) "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{print $2}')"
  opensearch_backend_2="$(VBoxManage guestproperty get $(cat .kitchen/kitchen-vagrant/opensearch-backend-2-$platform/.vagrant/machines/default/virtualbox/id) "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{print $2}')"
  opensearch_backend_3="$(VBoxManage guestproperty get $(cat .kitchen/kitchen-vagrant/opensearch-backend-3-$platform/.vagrant/machines/default/virtualbox/id) "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{print $2}')"
  bastion="$(VBoxManage guestproperty get $(cat .kitchen/kitchen-vagrant/bastion-$platform/.vagrant/machines/default/virtualbox/id) "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{print $2}')"
fi

# Write IPs to json file
cat <<-EOF | tee kitchen_nodes.json
  {
    "bastion": ["$bastion"],
    "chef_frontend": ["$chef_frontend_1"],
    "automate_frontend": ["$automate_frontend_1"],
    "postgres_backend": ["$postgres_backend_1", "$postgres_backend_2", "$postgres_backend_3"],
    "opensearch_backend": ["$opensearch_backend_1", "$opensearch_backend_2", "$opensearch_backend_3"]
  }
EOF

# Converge kitchen nodes
echo "**** Starting kitchen converge $platform ****"
kitchen converge end-[0-9]-$platform
kitchen converge bastion-$platform

echo "**** Script complete ****"
