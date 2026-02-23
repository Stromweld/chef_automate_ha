#!/usr/bin/env bash
##############################################
#
# Automate HA Test setup
# Run from local workstation
#
##############################################

# Stop on error
set -e

start_time=$(date +%s)

export KITCHEN_LOCAL_YAML=kitchen.ec2.yml

platform="rhel-8"
terraform init --upgrade
terraform apply -auto-approve


# Bring up kitchen nodes
echo "**** Starting kitchen create $platform ****"
kitchen create fe-.*-[0-9]-"$platform"
kitchen create be-.*-[0-9]-"$platform"
kitchen create bastion-"$platform"

sleep 5

echo "**** Writing IP's of machines to kitchen_nodes.json ****"
fe_auto_1="$(aws --profile saml ec2 describe-instances --instance-ids "$(grep server_id .kitchen/fe-auto-1-"$platform".yml | cut -d ' ' -f 2)" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
fe_auto_2="$(aws --profile saml ec2 describe-instances --instance-ids "$(grep server_id .kitchen/fe-auto-2-"$platform".yml | cut -d ' ' -f 2)" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
fe_chef_1="$(aws --profile saml ec2 describe-instances --instance-ids "$(grep server_id .kitchen/fe-chef-1-"$platform".yml | cut -d ' ' -f 2)" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
fe_chef_2="$(aws --profile saml ec2 describe-instances --instance-ids "$(grep server_id .kitchen/fe-chef-2-"$platform".yml | cut -d ' ' -f 2)" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
be_pg_1="$(aws --profile saml ec2 describe-instances --instance-ids "$(grep server_id .kitchen/be-pg-1-"$platform".yml | cut -d ' ' -f 2)" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
be_pg_2="$(aws --profile saml ec2 describe-instances --instance-ids "$(grep server_id .kitchen/be-pg-2-"$platform".yml | cut -d ' ' -f 2)" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
be_pg_3="$(aws --profile saml ec2 describe-instances --instance-ids "$(grep server_id .kitchen/be-pg-3-"$platform".yml | cut -d ' ' -f 2)" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
be_os_1="$(aws --profile saml ec2 describe-instances --instance-ids "$(grep server_id .kitchen/be-os-1-"$platform".yml | cut -d ' ' -f 2)" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
be_os_2="$(aws --profile saml ec2 describe-instances --instance-ids "$(grep server_id .kitchen/be-os-2-"$platform".yml | cut -d ' ' -f 2)" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
be_os_3="$(aws --profile saml ec2 describe-instances --instance-ids "$(grep server_id .kitchen/be-os-3-"$platform".yml | cut -d ' ' -f 2)" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"
bastion="$(aws --profile saml ec2 describe-instances --instance-ids "$(grep server_id .kitchen/bastion-"$platform".yml | cut -d ' ' -f 2)" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text --region us-west-2)"

# Write IPs to json file
cat <<-EOF | tee kitchen_nodes.json
{
  "bastion": ["$bastion"],
  "chef_frontend": ["$fe_chef_1", "$fe_chef_2"],
  "automate_frontend": ["$fe_auto_1", "$fe_auto_2"],
  "postgres_backend": ["$be_pg_1", "$be_pg_2", "$be_pg_3"],
  "opensearch_backend": ["$be_os_1", "$be_os_2", "$be_os_3"]
}
EOF

# Converge frontend/backend nodes
echo "**** Starting kitchen converge frontend/backend $platform ****"
kitchen converge fe-.*-[0-9]-"$platform"
kitchen converge be-.*-[0-9]-"$platform"

# Converge bastion node
echo "**** Starting kitchen converge bastion-$platform ****"
kitchen converge bastion-"$platform"

end_time=$(date +%s)
duration=$((end_time - start_time))/60
minutes=$((duration / 60))
seconds=$((duration % 60))

echo "**** Script complete in $minutes:$seconds minutes ****"
