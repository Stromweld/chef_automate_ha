#
# Cookbook:: automate_ha
# Attributes:: default
#
# Copyright:: 2022, Corey Hemminger
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

secrets = data_bag_item('ssh', 'keys')

default['automate_ha']['accept_license'] = true
default['automate_ha']['version'] = 'latest'

default['automate_ha']['username'] = 'chef'
default['automate_ha']['ssh_key'] = lazy { secrets[node['automate_ha']['username']] } # For testing purposes only please change, preferably get through your secrets manager
default['automate_ha']['ssh_authorize_key'] = {
  automate_ha: {
    key: 'AAAAC3NzaC1lZDI1NTE5AAAAIH7peqKl6c5BVpsnFDZi092wMwu9oonUHNz4oEQ4evn2', # For testing purposes only please change, preferably get through your secrets manager
    user: lazy { node['automate_ha']['username'] },
    keytype: 'ssh-ed25519',
    options: nil,
  },
}

default['automate_ha']['dns_configured'] = false
default['automate_ha']['automate_dns_entry'] = 'chef-automate.example.com'
default['automate_ha']['infra-server_dns_entry'] = 'chef-server.example.com'
default['automate_ha']['instance_ips'] = if kitchen?
                                           curdir = ::File.join(::File.dirname(::File.expand_path(__FILE__)), '..')
                                           JSON.parse(IO.read(curdir + '/kitchen_nodes.json'))
                                         else
                                           {
                                             chef_frontend: %w(10.0.0.1),
                                             automate_frontend: %w(10.0.0.2),
                                             postgres_backend: %w(10.0.0.3 10.0.0.4 10.0.0.5),
                                             opensearch_backend: %w(10.0.0.3 10.0.0.4 10.0.0.5),
                                           }
                                         end

# Only used for initial config any changes after should be made in custom_config_toml_template using similar format below
default['automate_ha']['initial_config_toml_template'] = {
  architecture: {
    existing_infra: {
      ssh_user: lazy { node['automate_ha']['username'] },
      ssh_group_name: lazy { node['automate_ha']['username'] },
      ssh_key_file: lazy { "#{Chef::Config[:file_cache_path]}/#{node['automate_ha']['username']}.key" },
      ssh_port: '22',
      secrets_key_file: '/hab/a2_deploy_workspace/secrets.key',
      secrets_store_file: '/hab/a2_deploy_workspace/secrets.json',
      architecture: 'existing_nodes',
      workspace_path: '/hab/a2_deploy_workspace',
      backup_mount: '/mnt/automate_backups', # DON'T MODIFY THIS LINE (backup_mount)
      backup_config: 'file_system', # Eg.: backup_config = "object_storage" or "file_system"
    },
  },
  # If backup_config = "object_storage" fill out [object_storage.config] as well
  object_storage: {
    config: {
      google_service_account_file: '',
      location: '',
      bucket_name: '',
      access_key: '',
      secret_key: '',
      endpoint: '',
      region: '',
    },
  },
  automate: {
    config: {
      admin_password: 'Test1234!',
      fqdn: lazy { node['automate_ha']['automate_dns_entry'] }, # Automate Load Balancer FQDN
      # root_ca: 'automate_lb_root_ca_contents',
      instance_count: lazy { node['automate_ha']['instance_ips']['automate_frontend'].length.to_s }, # No. of Automate Frontend Machines or VMs
      # teams_port: '',
      config_file: 'configs/automate.toml',
      enable_custom_certs: false,
      # private_key: 'private_key_contents',
      # public_key: 'public_key_contents',
      # certs_by_ip: {
        # ip: '',
        # private_key: 'private_key_contents',
        # public_key: 'public_key_contents',
      # },
    },
  },
   chef_server: {
    config: {
      fqdn: lazy { node['automate_ha']['infra-server_dns_entry'] }, # Chefserver Load Balancer FQDN
      # lb_root_ca: 'chef_server_lb_root_ca_contents',
      instance_count: lazy { node['automate_ha']['instance_ips']['chef_frontend'].length.to_s }, # No. of Chef Server Frontend Machines or VMs
      enable_custom_certs: false,
      # private_key: 'private_key_contents',
      # public_key: 'public_key_contents',
      # certs_by_ip: {
        # ip: '',
        # private_key: 'private_key_contents',
        # public_key: 'public_key_contents',
      # },
    },
   },
  opensearch: {
    config: {
      instance_count: lazy { node['automate_ha']['instance_ips']['opensearch_backend'].length.to_s }, # No. of OpenSearch DB Backend Machines or VMs
      enable_custom_certs: false,
      # root_ca: 'opensearch_root_ca_contents',
      # admin_key: 'admin_private_key_contents',
      # admin_cert: 'admin_public_key_contents',
      # private_key: 'private_key_contents',
      # public_key: 'public_key_contents',
      # certs_by_ip: {
        # ip: '',
        # private_key: 'private_key_contents',
        # public_key: 'public_key_contents',
      # },
    },
  },
  postgresql: {
    config: {
      instance_count: lazy { node['automate_ha']['instance_ips']['postgres_backend'].length.to_s }, # No. of Postgresql DB Backend Machines or VMs
      enable_custom_certs: false,
      # root_ca: 'postgresql_root_ca_contents',
      # private_key: 'private_key_contents',
      # public_key: 'public_key_contents',
      # certs_by_ip: {
        # ip: '',
        # private_key: 'private_key_contents',
        # public_key: 'public_key_contents',
      # },
    },
  },
  existing_infra: {
    config: {
      automate_private_ips: lazy { node['automate_ha']['instance_ips']['automate_frontend'] },
      chef_server_private_ips: lazy { node['automate_ha']['instance_ips']['chef_frontend'] },
      opensearch_private_ips: lazy { node['automate_ha']['instance_ips']['postgres_backend'] },
      postgresql_private_ips: lazy { node['automate_ha']['instance_ips']['opensearch_backend'] },
    },
  },
  external: {
    database: {
      type: '', # eg type = "aws" or "self-managed"
      postgresql: {
        instance_url: '',
        superuser_username: '',
        superuser_password: '',
        dbuser_username: '',
        dbuser_password: '',
        postgresql_root_cert: '',
      },
      open_search: {
        opensearch_domain_name: '',
        opensearch_domain_url: '',
        opensearch_username: '',
        opensearch_user_password: '',
        opensearch_root_cert: '',
        aws: {
          aws_os_snapshot_role_arn: '',
          os_snapshot_user_access_key_id: '',
          os_snapshot_user_access_key_secret: '',
        },
      },
    },
  },
}

# Used for patch changes to the system
default['automate_ha']['patch_config_toml_template'] = nil
