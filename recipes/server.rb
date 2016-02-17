#
# Cookbook Name:: arcgis
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

arcgis_server 'ArcGIS for Server system requirements' do
  action :system
end

arcgis_server 'Setup ArcGIS for Server' do
  setup node['arcgis']['server']['setup']
  install_dir node['arcgis']['server']['install_dir']
  python_dir node['arcgis']['python']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  action :install
end

arcgis_server 'Authorize ArcGIS for Server' do
  authorization_file node['arcgis']['server']['authorization_file']
  authorization_file_version node['arcgis']['server']['authorization_file_version']
  action :authorize
end

directory node['arcgis']['server']['directories_root'] do
  owner node['arcgis']['run_as_user']
  if node['platform'] != 'windows'
    group 'root'
    mode '0755'
  end
  recursive true
  not_if { node['arcgis']['server']['directories_root'].start_with?('\\\\') || 
           node['arcgis']['server']['directories_root'].start_with?('/net') }
  action :create
end

arcgis_server 'Create ArcGIS for Server Site' do
  server_url node['arcgis']['server']['local_url']
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  server_directories_root node['arcgis']['server']['directories_root']
  system_properties node['arcgis']['server']['system_properties']
  config_store_connection_string node['arcgis']['server']['config_store_connection_string']
  config_store_connection_secret node['arcgis']['server']['config_store_connection_secret']
  config_store_type node['arcgis']['server']['config_store_type']
  retries 5
  retry_delay 30
  action :create_site
end

arcgis_server 'Configure HTTPS' do
  server_url node['arcgis']['server']['local_url']
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  keystore_file node['arcgis']['server']['keystore_file']
  keystore_password node['arcgis']['server']['keystore_password']
  cert_alias node['arcgis']['server']['cert_alias']
  retries 5
  retry_delay 30
  not_if { node['arcgis']['server']['keystore_file'].nil? }
  action :configure_https
end