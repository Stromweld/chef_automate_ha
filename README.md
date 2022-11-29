# automate_ha

This Cookbook will install and configure Chef Automate HA Feature on all your on-prem nodes

Use of this cookbook for installing Chef Automate means you agree to the license terms found at <https://www.chef.io/end-user-license-agreement>

## Requirements

- Please see <https://docs.chef.io/automate/ha_platform_support/> for server hardware requirements
- Latest chef-workstation installed
- For test-kitchen testing locally you'll need about 22GB of local ram for the VM's themselves
- When using test-kitchen run the `start_kitchen_test.sh` in a bash window to automate the creation of the machines, gathering of the IP's, and writing out kitchen_nodes.json with the IP's for the config.toml file generation

### Platforms

- Linux

## Attributes

### default attributes

| Attribute | Default | Type | Comment |
|-----------|---------|------|---------|
| ['automate_ha']['accept_license'] | true | Boolean | Consents to the license agreement at <https://www.chef.io/end-user-license-agreement> |
| ['automate_ha']['version'] | 'latest' | String | Version of Automate to install. HA requires version 4.3.x or newer |
| ['automate_ha']['username'] | 'automate_ha' | String | Username for SSH access to nodes in cluster |
| ['automate_ha']['ssh_key'] | see attribute file | String | SSH private key used for access to nodes, this should be replaced by one preferably from a secrets manager, this one is ok for testing with test-kitchen locally
| ['automate_ha']['ssh_authorize_key'] | see attribute file | String | SSH public key added to the user's authorized_keys file for ssh key based access to nodes |
| ['automate_ha']['dns_configured'] | false | boolean | Specifies if /etc/hosts needs to be modified if automate and chef dns entries aren't configured and resolvable locally |
| ['automate_ha']['automate_dns_entry'] | 'chef-automate.example.com' | String | Url used to resolve connection to the automate frontends |
| ['automate_ha']['infra-server_dns_entry'] | 'chef-server.example.com' | String | Url used to resolve connection to the chef infra server frontends |
| ['automate_ha']['instance_ips'] | {chef_frontend: %w(10.0.0.1), automate_frontend: %w(10.0.0.2), postgres_backend: %w(10.0.0.3 10.0.0.4 10.0.0.5), opensearch_backend: %w(10.0.0.6 10.0.0.7 10.0.0.8)} | Hash | Key value pairs defining all IP's of nodes in the cluster |
| ['automate_ha']['initial_config_toml_template'] | See attribute file | Hash | Hash of values used to generate the config.toml file for initial deployment of Automate HA across all nodes in the cluster, not to be used for patch config changes |
| ['automate_ha']['patch_config_toml_template'] | nil | Hash | Hash of values used to generate a patch_config.toml file for modifying cluster configuration after initial deployment |

## Recipes

### default recipe

Used on all nodes to:

- Create the user for ssh access
- Add ssh public key to users authorized_keys file for ssh access
- Ensures user has full sudo access without password
- Add /etc/hosts file entries for automate and infra server urls if DNS is not configured
- Sets SElinux policy to permissive

### bastion

Should only run on the bastion host to:

- Create ssh private key in chef cache directory for ssh access to all nodes
- Download, extract and link the chef-automate binary to the OS default bin folder
- Downloads the automate.aib file for deployment in the chef cache directory
- Sets sysctl settings needed for automate deployment
- Generates config.toml file in chef cache directory for initial deployment
- Executes command for inital Automate HA deployment for all servers

## Usage

1. Set attributes and runlist via wrapper cookbook, policy files, role or environment files.
1. Build cluster servers with runlist `automate_ha::default`
1. Build bastion server with runlist `["automate_ha::default", "automate_ha::bastion"]`

## Test-kitchen Usage

1. In terminal run script `start_kitchen_test.sh`
1. To use a different platform found in the kitchen.yml file add the platform as parameter `start_kitchen_test.sh centos-7`
1. To specify alternate virtualization platform for vagrant like parallels set environment variable `VAGRANT_DEFAULT_PROVIDER` to the name of the provider desired
2. To use another kitchen file setup set `KITCHEN_LOCAL_YAML` to point to another kitchen file that overrides values in the default kitchen.yml file
1. After all servers are up and converged run normal `kitchen` commands as needed
