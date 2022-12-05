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

default['automate_ha']['username'] = 'automate_ha'
default['automate_ha']['ssh_key'] = lazy { secrets[node['automate_ha']['username']] } # For testing purposes only please change, preferably get through your secrets manager
default['automate_ha']['ssh_authorize_key'] = {
  automate_ha: {
    key: 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC8Izt8mEkJt4o3qVDsWcBQ265QRQGi0z3A5QTnm0CMgiyPjHj9KpZbuNShY2gGa1uZ/V7n4oQLRDoVX9fCOri4n9Bf6klYCAlQRyvBtZSi86FJ1EZwiU9O9Abbbc39vkWJBqrX3mfd+txNBN+A1y+6gCjOaaA26jGEMibKVWWKBv22Ja7XWosHwcgXuzO3rsgr+Y3B8cVnQBUQG77iSzW4RAL9vJ1M1ETzCGJ+RAoQ9064AjFnYu0PB/7NcKWH05GdzmEz+xPD4N6qp6OXVPJO0AUwMAVyxPOHIUAUvBixSXIvTKnD1S/L4/aUoGdMF2hXX/96Qcwxfw4CQBzhRAaf', # For testing purposes only please change, preferably get through your secrets manager
    user: lazy { node['automate_ha']['username'] },
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
                                             opensearch_backend: %w(10.0.0.6 10.0.0.7 10.0.0.8),
                                           }
                                         end

# Only used for initial config any changes after should be made in custom_config_toml_template using similar format below
default['automate_ha']['initial_config_toml_template'] = {
  architecture: {
    existing_infra: {
      ssh_user: lazy { node['automate_ha']['username'] },
      ssh_key_file: "#{Chef::Config[:file_cache_path]}/automate_ha.key",
      ssh_port: '22',
      sudo_password: '', # Provide Password if needed to run sudo commands.
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
      instance_count: lazy { node['automate_ha']['instance_ips']['automate_frontend'].length.to_s }, # No. of Automate Frontend Machine or VM
      # teams_port: "",
      config_file: 'configs/automate.toml',
      root_ca: '',
      public_key: '',
      private_key: '',
      custom_certs_enabled: false,
    },
  },
  chef_server: {
    config: {
      instance_count: lazy { node['automate_ha']['instance_ips']['chef_frontend'].length.to_s }, # No. of Chef Server Frontend Machine or VM
      root_ca: '',
      public_key: '',
      private_key: '',
      custom_certs_enabled: false,
    },
  },
  opensearch: {
    config: {
      instance_count: lazy { node['automate_ha']['instance_ips']['opensearch_backend'].length.to_s }, # No. of OpenSearch DB Backend Machine or VM
      root_ca: '',
      public_key: '',
      private_key: '',
      custom_certs_enabled: false,
    },
  },
  postgresql: {
    config: {
      instance_count: lazy { node['automate_ha']['instance_ips']['postgres_backend'].length.to_s }, # No. of Postgresql DB Backend Machine or VM
      root_ca: '',
      public_key: '',
      private_key: '',
      custom_certs_enabled: false,
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
}

# Used for patch changes to the system
default['automate_ha']['patch_config_toml_template'] = nil
