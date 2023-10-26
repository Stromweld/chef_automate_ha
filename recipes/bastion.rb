#
# Cookbook:: automate_ha
# Recipe:: bastion
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

# Create automate_ha user ssh private key in root's .ssh folder
file "#{Chef::Config[:file_cache_path]}/#{node['automate_ha']['username']}.key" do
  content node['automate_ha']['ssh_key']
  owner 'root'
  group 'root'
  mode '0600'
  sensitive true
end

bin_path = value_for_platform_family(
  debian: '/bin',
  default: '/usr/bin'
)

remote_file "#{Chef::Config[:file_cache_path]}/chef-automate-#{node['automate_ha']['version']}.zip" do
  source "https://packages.chef.io/files/current/#{node['automate_ha']['version']}/chef-automate-cli/chef-automate_linux_amd64.zip"
end

archive_file "#{Chef::Config[:file_cache_path]}/chef-automate-#{node['automate_ha']['version']}.zip" do
  destination '/usr/local/chef-automate'
  mode '0755'
end

link "#{bin_path}/chef-automate" do
  to '/usr/local/chef-automate/chef-automate'
end

remote_file "#{Chef::Config[:file_cache_path]}/automate-#{node['automate_ha']['version']}.aib" do
  source "https://packages.chef.io/airgap_bundle/current/automate/#{node['automate_ha']['version']}.aib"
end

sysctl 'vm.max_map_count' do
  value 262144
end

sysctl 'vm.dirty_expire_centisecs' do
  value 20000
end

template "#{Chef::Config[:file_cache_path]}/deploy-config.toml" do
  source 'config.toml.erb'
  variables(var: render_toml(node['automate_ha']['initial_config_toml_template']))
  notifies :run, 'execute[Run Deployment Command]', :immediately
end

execute 'Run Deployment Command' do
  command "chef-automate deploy #{Chef::Config[:file_cache_path]}/deploy-config.toml --skip-verify --airgap-bundle #{Chef::Config[:file_cache_path]}/automate-#{node['automate_ha']['version']}.aib #{'--accept-terms-and-mlsa' if node['automate_ha']['accept_license']}"
  cwd Chef::Config[:file_cache_path]
  live_stream true
  user 'root'
  timeout 7200
  not_if 'chef-automate status'
  notifies :run, 'execute[chef-automate status]', :delayed
end

execute 'chef-automate status' do
  cwd Chef::Config[:file_cache_path]
  live_stream true
  user 'root'
  action :nothing
end

if node['automate_ha']['patch_config_toml_template']
  template "#{Chef::Config[:file_cache_path]}/patch_config.toml" do
    source 'config.toml.erb'
    variables(var: render_toml(node['automate_ha']['patch_config_toml_template']))
    notifies :run, "execute[chef-automate config patch #{Chef::Config[:file_cache_path]}/patch_config.toml]", :immediately
  end

  execute "chef-automate config patch #{Chef::Config[:file_cache_path]}/patch_config.toml" do
    cwd Chef::Config[:file_cache_path]
    live_stream true
    action :nothing
  end
end
