#
# Cookbook Name:: arcgis-server
# Recipe:: server_node
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
  arcgis_server_server 'Update ArcGIS Server service logon account' do
    run_as_user node['arcgis']['run_as_user']
    run_as_password node['arcgis']['run_as_password']
    only_if { Utils.product_installed?(node['arcgis']['server']['product_code']) }
    subscribes :update_account, "user[#{node['arcgis']['run_as_user']}]", :immediately
    action :nothing
  end
end

arcgis_server_server "Install System Requirements:#{recipe_name}" do
  action :system
  only_if { node['arcgis']['server']['install_system_requirements'] }
end

arcgis_server_server 'Setup ArcGIS Server' do
  setup node['arcgis']['server']['setup']
  install_dir node['arcgis']['server']['install_dir']
  python_dir node['arcgis']['python']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['server']['product_code']) }
  else
    not_if { ::File.exist?(::File.join(node['arcgis']['server']['install_dir'],
                                       node['arcgis']['server']['install_subdir'],
                                       'startserver.sh')) }
  end
  action :install
end

arcgis_server_server 'Configure arcgisserver service' do
  install_dir node['arcgis']['server']['install_dir']
  only_if { node['arcgis']['server']['configure_autostart'] }
  action :configure_autostart
end

arcgis_server_server 'Authorize ArcGIS Server' do
  authorization_file node['arcgis']['server']['authorization_file']
  authorization_file_version node['arcgis']['server']['authorization_file_version']
  retries 5
  retry_delay 60
  not_if { ::File.exists?(node['arcgis']['server']['cached_authorization_file']) &&
           FileUtils.compare_file(node['arcgis']['server']['authorization_file'],
                                  node['arcgis']['server']['cached_authorization_file']) }
  action :authorize
end

file node['arcgis']['server']['cached_authorization_file'] do
  content File.open(node['arcgis']['server']['authorization_file'], 'rb') { |file| file.read }
  sensitive true
  subscribes :create, 'arcgis_server_server[Authorize ArcGIS Server]', :immediately
  only_if { node['arcgis']['cache_authorization_files'] }
  action :nothing
end

arcgis_server_server 'Start ArcGIS Server' do
  action :start
end

arcgis_server_server 'Join ArcGIS Server Site' do
  server_url node['arcgis']['server']['url']
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  primary_server_url node['arcgis']['server']['primary_server_url']
  retries 10
  retry_delay 30
  action :join_site
end

arcgis_server_server 'Add machine to default cluster' do
  server_url node['arcgis']['server']['url']
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  cluster 'default'
  retries 10
  retry_delay 30
  action :join_cluster
end

arcgis_server_server 'Configure HTTPS' do
  server_url node['arcgis']['server']['url']
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
