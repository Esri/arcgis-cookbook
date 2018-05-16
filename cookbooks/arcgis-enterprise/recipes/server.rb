#
# Cookbook Name:: arcgis-enterprise
# Recipe:: server
#
# Copyright 2015 Esri
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
#

if node['platform'] == 'windows'
  arcgis_enterprise_server 'Update ArcGIS Server service logon account' do
    install_dir node['arcgis']['server']['install_dir']
    run_as_user node['arcgis']['run_as_user']
    run_as_password node['arcgis']['run_as_password']
    only_if { Utils.product_installed?(node['arcgis']['server']['product_code']) }
    subscribes :update_account, "user[#{node['arcgis']['run_as_user']}]", :immediately
    action :nothing
  end
end

arcgis_enterprise_server "Install System Requirements:#{recipe_name}" do
  action :system
  only_if { node['arcgis']['server']['install_system_requirements'] }
end

arcgis_enterprise_server 'Unpack ArcGIS Server Setup' do
  setup_archive node['arcgis']['server']['setup_archive']
  setups_repo node['arcgis']['repository']['setups']
  run_as_user node['arcgis']['run_as_user']
  only_if { ::File.exist?(node['arcgis']['server']['setup_archive']) &&
            !::File.exist?(node['arcgis']['server']['setup']) }
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['server']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                               node['hostname'],
                                               node['arcgis']['version'],
                                               :ArcGISServer) }
  end
  action :unpack
end

arcgis_enterprise_server 'Setup ArcGIS Server' do
  setup node['arcgis']['server']['setup']
  install_dir node['arcgis']['server']['install_dir']
  python_dir node['arcgis']['python']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['server']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                               node['hostname'],
                                               node['arcgis']['version'],
                                               :ArcGISServer) }
  end
  action :install
end

arcgis_enterprise_server 'Configure arcgisserver service' do
  install_dir node['arcgis']['server']['install_dir']
  only_if { node['arcgis']['server']['configure_autostart'] }
  action :configure_autostart
end

arcgis_enterprise_server 'Authorize ArcGIS Server' do
  authorization_file node['arcgis']['server']['authorization_file']
  authorization_file_version node['arcgis']['server']['authorization_file_version']
  retries 2
  retry_delay 30
  not_if { ::File.exists?(node['arcgis']['server']['cached_authorization_file']) &&
           FileUtils.compare_file(node['arcgis']['server']['authorization_file'],
                                  node['arcgis']['server']['cached_authorization_file']) }
  action :authorize
end

# Copy server authorization file to the machine to indicate that server is already authorized
file 'Cache server authorization file' do
  path node['arcgis']['server']['cached_authorization_file']
  if ::File.exists?(node['arcgis']['server']['authorization_file'])
    content File.open(node['arcgis']['server']['authorization_file'], 'rb') { |file| file.read }
  end
  sensitive true
  subscribes :create, 'arcgis_enterprise_server[Authorize ArcGIS Server]', :immediately
  only_if { node['arcgis']['cache_authorization_files'] }
  action :nothing
end

arcgis_enterprise_server 'Start ArcGIS Server' do
  action :start
end

directory node['arcgis']['server']['directories_root'] do
  owner node['arcgis']['run_as_user']
  if node['platform'] != 'windows'
    mode '0700'
  end
  recursive true
  not_if { node['arcgis']['server']['directories_root'].start_with?('\\\\') ||
           node['arcgis']['server']['directories_root'].start_with?('/net') }

  action :create
end

arcgis_enterprise_server 'Create ArcGIS Server site' do
  server_url node['arcgis']['server']['url']
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  server_directories_root node['arcgis']['server']['directories_root']
  system_properties node['arcgis']['server']['system_properties']
  log_level node['arcgis']['server']['log_level']
  log_dir node['arcgis']['server']['log_dir']
  max_log_file_age node['arcgis']['server']['max_log_file_age']
  config_store_connection_string node['arcgis']['server']['config_store_connection_string']
  config_store_connection_secret node['arcgis']['server']['config_store_connection_secret']
  config_store_type node['arcgis']['server']['config_store_type']
  retries 5
  retry_delay 30
  action :create_site
end

arcgis_enterprise_server 'Set server machine properties' do
  server_url node['arcgis']['server']['url']
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  soc_max_heap_size node['arcgis']['server']['soc_max_heap_size']
  retries 5
  retry_delay 30
  action :set_machine_properties
end

arcgis_enterprise_server 'Configure HTTPS' do
  server_url node['arcgis']['server']['url']
  server_admin_url node['arcgis']['server']['private_url'] + '/admin'
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  keystore_file node['arcgis']['server']['keystore_file']
  keystore_password node['arcgis']['server']['keystore_password']
  cert_alias node['arcgis']['server']['cert_alias']
  retries 5
  retry_delay 30
  not_if { node['arcgis']['server']['keystore_file'].empty? }
  action :configure_https
end

# Restart ArcGIS Server
arcgis_enterprise_server 'Start ArcGIS Server' do
  action :stop
end

arcgis_enterprise_server 'Start ArcGIS Server' do
  action :start
end
