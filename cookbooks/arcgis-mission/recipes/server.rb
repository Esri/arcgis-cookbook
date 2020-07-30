#
# Cookbook Name:: arcgis-mission
# Recipe:: server
#
# Copyright 2020 Esri
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

include_recipe 'arcgis-mission::install_server'

arcgis_mission_server 'Authorize ArcGIS Mission Server' do
  authorization_file node['arcgis']['mission_server']['authorization_file']
  authorization_file_version node['arcgis']['mission_server']['authorization_file_version']
  retries 2
  retry_delay 30
  notifies :stop, 'arcgis_mission_server[Stop ArcGIS Mission Server]', :immediately
  action :authorize
end

# Restart ArcGIS Mission Server
arcgis_mission_server 'Stop ArcGIS Mission Server' do
  action :nothing
end

arcgis_mission_server 'Start ArcGIS Mission Server' do
  action :start
end

directory node['arcgis']['mission_server']['directories_root'] do
  owner node['arcgis']['run_as_user']
  if node['platform'] != 'windows'
    mode '0700'
  end
  recursive true
  not_if { node['arcgis']['mission_server']['directories_root'].start_with?('\\\\') ||
           node['arcgis']['mission_server']['directories_root'].start_with?('/net/') }
  action :create
end

# Create configuration store directory
directory node['arcgis']['mission_server']['config_store_connection_string'] do
  owner node['arcgis']['run_as_user']
  if node['platform'] != 'windows'
    mode '0700'
  end
  recursive true
  not_if { node['arcgis']['mission_server']['config_store_connection_string'].start_with?('\\\\') ||
           node['arcgis']['mission_server']['config_store_connection_string'].start_with?('/net/') }
  action :create
end

arcgis_mission_server 'Create ArcGIS Mission Server site' do
  install_dir node['arcgis']['mission_server']['install_dir']
  server_url node['arcgis']['mission_server']['url']
  username node['arcgis']['mission_server']['admin_username']
  password node['arcgis']['mission_server']['admin_password']
  server_directories_root node['arcgis']['mission_server']['directories_root']
  config_store_connection_string node['arcgis']['mission_server']['config_store_connection_string']
  system_properties node['arcgis']['mission_server']['system_properties']
  retries 5
  retry_delay 30
  action :create_site
end
