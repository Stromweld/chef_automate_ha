#!/usr/bin/env bash
##############################################
#
# Automate HA Test setup
# Run from local workstation
#
##############################################

# Stop on error
set -e

if [[ -z "$1" ]]
  then
    if [[ "$KITCHEN_LOCAL_YAML" == "kitchen.ec2.yml" ]]
      then
        platform="rhel-8"
    else
      platform="rockylinux-8"
    fi
else
  platform="$1"
fi

# Bring up kitchen nodes
echo "**** Starting kitchen create $platform ****"
kitchen create $platform

sleep 5

echo "**** Writing IP's of machines to kitchen_nodes.json ****"
if [[ "$KITCHEN_LOCAL_YAML" == "kitchen.ec2.yml" ]]
  then
    frontend_1="$(aws --profile saml ec2 describe-instances --instance-ids $(cat .kitchen/frontend-1-$platform.yml | grep server_id | cut -d ' ' -f 2) --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
    frontend_2="$(aws --profile saml ec2 describe-instances --instance-ids $(cat .kitchen/frontend-2-$platform.yml | grep server_id | cut -d ' ' -f 2) --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
    backend_1="$(aws --profile saml ec2 describe-instances --instance-ids $(cat .kitchen/backend-1-$platform.yml | grep server_id | cut -d ' ' -f 2) --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
    backend_2="$(aws --profile saml ec2 describe-instances --instance-ids $(cat .kitchen/backend-2-$platform.yml | grep server_id | cut -d ' ' -f 2) --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
    backend_3="$(aws --profile saml ec2 describe-instances --instance-ids $(cat .kitchen/backend-3-$platform.yml | grep server_id | cut -d ' ' -f 2) --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
    bastion="$(aws --profile saml ec2 describe-instances --instance-ids $(cat .kitchen/bastion-$platform.yml | grep server_id | cut -d ' ' -f 2) --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
elif [[ "$VAGRANT_DEFAULT_PROVIDER" == "parallels" ]]
  then
    # Get external IPs
    frontend_1="$(prlctl exec $(cat .kitchen/kitchen-vagrant/frontend-1-$platform/.vagrant/machines/default/parallels/id) ip -o -f inet address show eth0 | cut -d ' ' -f7 | cut -d '/' -f1)"
    frontend_2="$(prlctl exec $(cat .kitchen/kitchen-vagrant/frontend-2-$platform/.vagrant/machines/default/parallels/id) ip -o -f inet address show eth0 | cut -d ' ' -f7 | cut -d '/' -f1)"
    backend_1="$(prlctl exec $(cat .kitchen/kitchen-vagrant/backend-1-$platform/.vagrant/machines/default/parallels/id) ip -o -f inet address show eth0 | cut -d ' ' -f7 | cut -d '/' -f1)"
    backend_2="$(prlctl exec $(cat .kitchen/kitchen-vagrant/backend-2-$platform/.vagrant/machines/default/parallels/id) ip -o -f inet address show eth0 | cut -d ' ' -f7 | cut -d '/' -f1)"
    backend_3="$(prlctl exec $(cat .kitchen/kitchen-vagrant/backend-3-$platform/.vagrant/machines/default/parallels/id) ip -o -f inet address show eth0 | cut -d ' ' -f7 | cut -d '/' -f1)"
    bastion="$(prlctl exec $(cat .kitchen/kitchen-vagrant/bastion-$platform/.vagrant/machines/default/parallels/id) ip -o -f inet address show eth0 | cut -d ' ' -f7 | cut -d '/' -f1)"
else
  # Get external IPs
  frontend_1="$(VBoxManage guestproperty get $(cat .kitchen/kitchen-vagrant/frontend-1-$platform/.vagrant/machines/default/virtualbox/id) "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{print $2}')"
  frontend_2="$(VBoxManage guestproperty get $(cat .kitchen/kitchen-vagrant/frontend-2-$platform/.vagrant/machines/default/virtualbox/id) "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{print $2}')"
  backend_1="$(VBoxManage guestproperty get $(cat .kitchen/kitchen-vagrant/backend-1-$platform/.vagrant/machines/default/virtualbox/id) "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{print $2}')"
  backend_2="$(VBoxManage guestproperty get $(cat .kitchen/kitchen-vagrant/backend-2-$platform/.vagrant/machines/default/virtualbox/id) "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{print $2}')"
  backend_3="$(VBoxManage guestproperty get $(cat .kitchen/kitchen-vagrant/backend-3-$platform/.vagrant/machines/default/virtualbox/id) "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{print $2}')"
  bastion="$(VBoxManage guestproperty get $(cat .kitchen/kitchen-vagrant/bastion-$platform/.vagrant/machines/default/virtualbox/id) "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{print $2}')"
fi

# Write IPs to json file
cat <<-EOF | tee kitchen_nodes.json
{
  "bastion": ["$bastion"],
  "chef_frontend": ["$frontend_1", "$frontend_2"],
  "automate_frontend": ["$frontend_1", "$frontend_2"],
  "postgres_backend": ["$backend_1", "$backend_2", "$backend_3"],
  "opensearch_backend": ["$backend_1", "$backend_2", "$backend_3"]
}
EOF

# Converge frontend/backend nodes
echo "**** Starting kitchen converge frontend/backend $platform ****"
kitchen converge end-[0-9]-$platform

# Converge bastion node
echo "**** Starting kitchen converge bastion-$platform ****"
kitchen converge bastion-$platform

echo "**** Script complete ****"
