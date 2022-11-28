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

default['automate_ha']['accept_license'] = true
default['automate_ha']['version'] = 'latest'

default['automate_ha']['username'] = 'automate_ha'
default['automate_ha']['ssh_key'] = <<-EOV
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAvCM7fJhJCbeKN6lQ7FnAUNuuUEUBotM9wOUE55tAjIIsj4x4
/SqWW7jUoWNoBmtbmf1e5+KEC0Q6FV/Xwjq4uJ/QX+pJWAgJUEcrwbWUovOhSdRG
cIlPTvQG223N/b5FiQaq195n3frcTQTfgNcvuoAozmmgNuoxhDImylVligb9tiWu
11qLB8HIF7szt67IK/mNwfHFZ0AVEBu+4ks1uEQC/bydTNRE8whifkQKEPdOuAIx
Z2LtDwf+zXClh9ORnc5hM/sTw+Deqqejl1TyTtAFMDAFcsTzhyFAFLwYsUlyL0yp
w9Uvy+P2lKBnTBdoV1//ekHMMX8OAkAc4UQGnwIDAQABAoIBAAMY9WbEvxcY3X6z
G/D4PVFXfJQ3vqImpjKh0qXZiYOGtSMb5fYNGHKkJWQO1eydIeH0KPbaZOAmnGoz
rMK24smvX+fkXJbFcxnOQisrSSoxpqsngo1hxVuAawh701NlKZHq+S8aq00dTzk5
ZlChulhwubtEQ+4DhxMtHDRimYxfL9t+cltgRx0Vx+30DgmnEorVo/P0oeFjl4K3
hds9g43evalKyMgQodLrB+mPGIwP+yEa09+3dNAxKnXW315xORN7QhEbI+rvfIQi
5tvKRy7xwA0hEwKpbghUMJLpkuBpqLBgUcA2iZOG7/ouiaH4NXFxivzNVjaRUau1
owORwmECgYEA55r6DFp+R1o4tUkkMO4as3yrc9uvAgEPj+zAB+bUHyu+Xkm04Hai
EZ2wbQC+TnAIO4ExHc9odnFA45Bcav+/uErIjJKXUb39/bo3WOen5UniMExa4s8+
UP1+E5q1S/BlhJzn+wRIvTyrYypV/O1gDk2blwPXJ77lJTGCrMN1izECgYEAz/Qw
LY/td8nLQ76yiOgojqgk3nGg/jvYhYoVHQ8R1Aajph5z6MPURfI0aSGzvE2ID2XN
wo9b2aLD3gZuVjdFE0j6jKe/GJqM4nPHmnpCxCDw6r8HKdGvwLn8Kwdlg+s7c50R
YBcHKMHfP2Xl3Ng6sasa54zhB6TF+41JP24Nms8CgYBV6SDTsEWjRg4/ANCR7eCt
r5MRuO2j+qzBIHri83a/0UQeSYz0rkzT6ABnjp0JD3meSP/lJOiE9uGxB/2gGxoM
zICz1DSZN7adhZO+QMAAx3VFoS0dcO6WsFEyCHMzpgqiNGnArQgmWfjhIfUfixXU
eGk8jUokDiWFtGXam+5gIQKBgQC88Ae13cbLxzQ+4MwlR4lR08Nrt6GmW4lmCwcT
19VC5qVZEOIO4Z3Dz0N/IXfD5k1wb/Z6hvXUzuVWnFEzVBQWaX/6u44MNJ88QCVi
XSK8P5GkNtuzSyh72n8aOSYqrVbevB5FR6bhiQPk/hfSh0MMmYFgT8dEwph+7OdY
Eg2aUQKBgQCbULLBxjLvnxev9PggV5OKzejUG5ptMQJPHS5xcUfq3ECFLslexDIV
CjH/1eWLUF+9C5xlAuK0nBLtKMrMo4l9ctbPUGu3o0xB2YQWNgmXf9YEPlebn6UK
Qy22Mbt4QmPB+plh+DT5+ABRrldCj81KfKPfNa3QS99TsYIyAEZ/7w==
-----END RSA PRIVATE KEY-----
EOV
default['automate_ha']['ssh_authorize_key'] = {
  automate_ha: {
    key: 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC8Izt8mEkJt4o3qVDsWcBQ265QRQGi0z3A5QTnm0CMgiyPjHj9KpZbuNShY2gGa1uZ/V7n4oQLRDoVX9fCOri4n9Bf6klYCAlQRyvBtZSi86FJ1EZwiU9O9Abbbc39vkWJBqrX3mfd+txNBN+A1y+6gCjOaaA26jGEMibKVWWKBv22Ja7XWosHwcgXuzO3rsgr+Y3B8cVnQBUQG77iSzW4RAL9vJ1M1ETzCGJ+RAoQ9064AjFnYu0PB/7NcKWH05GdzmEz+xPD4N6qp6OXVPJO0AUwMAVyxPOHIUAUvBixSXIvTKnD1S/L4/aUoGdMF2hXX/96Qcwxfw4CQBzhRAaf',
    user: lazy { node['automate_ha']['username'] },
    options: nil
  }
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
                                                     opensearch_backend: %w(10.0.0.6 10.0.0.7 10.0.0.8)
                                                   }
                                                 end

# Only used for initial config any changes after should be made in custom_config_toml_template using similar format below
default['automate_ha']['initial_config_toml_template'] = {
  architecture: {
    existing_infra: {
      ssh_user: lazy { node['automate_ha']['username'] },
      ssh_key_file: "#{Chef::Config[:file_cache_path]}/automate_ha.key",
      ssh_port: '22',
      sudo_password: "", # Provide Password if needed to run sudo commands.
      secrets_key_file: "/hab/a2_deploy_workspace/secrets.key",
      secrets_store_file: "/hab/a2_deploy_workspace/secrets.json",
      architecture: "existing_nodes",
      workspace_path: "/hab/a2_deploy_workspace",
      backup_mount: "/mnt/automate_backups", # DON'T MODIFY THIS LINE (backup_mount)
      backup_config: 'file_system', # Eg.: backup_config = "object_storage" or "file_system"
    },
  },
  # If backup_config = "object_storage" fill out [object_storage.config] as well
  object_storage: {
    config: {
      bucket_name: "",
      access_key: "",
      secret_key: "",
      endpoint: "",
      region: ""
    },
  },
  automate: {
    config: {
      admin_password: "Test1234!",
      fqdn: "chefautomate.example.com", # Automate Load Balancer FQDN
      instance_count: lazy { node['automate_ha']['instance_ips']['automate_frontend'].length.to_s }, # No. of Automate Frontend Machine or VM
      # teams_port: "",
      config_file: "configs/automate.toml"
    },
  },
  chef_server: {
    config: {
      instance_count: lazy { node['automate_ha']['instance_ips']['chef_frontend'].length.to_s }, # No. of Chef Server Frontend Machine or VM
    },
  },
  opensearch: {
    config: {
      instance_count: lazy { node['automate_ha']['instance_ips']['opensearch_backend'].length.to_s }, # No. of OpenSearch DB Backend Machine or VM
    },
  },
  postgresql: {
    config: {
      instance_count: lazy { node['automate_ha']['instance_ips']['postgres_backend'].length.to_s }, # No. of Postgresql DB Backend Machine or VM
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
