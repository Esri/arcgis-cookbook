#
# Cookbook Name:: arcgis-notebooks
# Recipe:: server
#
# Copyright 2019 Esri
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

include_recipe 'arcgis-notebooks::install_server'

arcgis_notebooks_server 'Start ArcGIS Notebook Server' do
  install_dir node['arcgis']['notebook_server']['install_dir']
  action :start
end

arcgis_notebooks_server 'Authorize ArcGIS Notebook Server' do
  authorization_file node['arcgis']['notebook_server']['authorization_file']
  authorization_file_version node['arcgis']['notebook_server']['authorization_file_version']
  retries 2
  retry_delay 30
  notifies :stop, 'arcgis_notebooks_server[Stop ArcGIS Notebook Server]', :immediately
  action :authorize
end

# Set hostname in hostname.properties file
template ::File.join(node['arcgis']['notebook_server']['install_dir'],
                     node['arcgis']['notebook_server']['install_subdir'],
                     'framework', 'etc', 'hostname.properties') do
  source 'hostname.properties.erb'
  variables ( {:hostname => node['arcgis']['notebook_server']['hostname']} )
  notifies :stop, 'arcgis_notebooks_server[Stop ArcGIS Notebook Server]', :immediately
  notifies :delete, 'directory[Delete ArcGIS Notebook Server certificates directory]', :immediately
  not_if { node['arcgis']['notebook_server']['hostname'].empty? }
end

# Restart ArcGIS Server
arcgis_notebooks_server 'Stop ArcGIS Notebook Server' do
  install_dir node['arcgis']['notebook_server']['install_dir']
  action :nothing
end

# Delete SSL certificates issued to the old hostname to make ArcGIS Notebook Server
# recreate the certificates for hostname set in hostname.properties file.
directory 'Delete ArcGIS Notebook Server certificates directory' do
  path ::File.join(node['arcgis']['notebook_server']['install_dir'],
                   node['arcgis']['notebook_server']['install_subdir'],
                   'framework', 'etc', 'certificates')
  # Do not delete certificates directory if ArcGIS Notebook Server site already exists.
  not_if { ::File.exist?(::File.join(node['arcgis']['notebook_server']['install_dir'],
                                     node['arcgis']['notebook_server']['install_subdir'],
                                     'framework', 'etc', 'config-store-connection.json')) }
  recursive true
  action :nothing
end

arcgis_notebooks_server 'Start ArcGIS Notebook Server' do
  install_dir node['arcgis']['notebook_server']['install_dir']
  action :start
end

directory node['arcgis']['notebook_server']['directories_root'] do
  owner node['arcgis']['run_as_user']
  if node['platform'] != 'windows'
    mode '0700'
  end
  recursive true
  not_if { node['arcgis']['notebook_server']['directories_root'].start_with?('\\\\') ||
           node['arcgis']['notebook_server']['directories_root'].start_with?('/net/') }
  action :create
end

directory node['arcgis']['notebook_server']['config_store_connection_string'] do
  owner node['arcgis']['run_as_user']
  if node['platform'] != 'windows'
    mode '0700'
  end
  recursive true
  only_if { node['arcgis']['notebook_server']['config_store_type'] == 'FILESYSTEM'}
  not_if { node['arcgis']['notebook_server']['config_store_connection_string'].start_with?('\\\\') ||
           node['arcgis']['notebook_server']['config_store_connection_string'].start_with?('/net/') }
  action :create
end

directory node['arcgis']['notebook_server']['workspace'] do
  owner node['arcgis']['run_as_user']
  recursive true
  only_if { node['platform'] == 'windows' }
  action :create
end

# Create local server logs directory
directory node['arcgis']['notebook_server']['log_dir'] do
  owner node['arcgis']['run_as_user']
  if node['platform'] != 'windows'
    mode '0775'
  end
  recursive true
  not_if { node['arcgis']['notebook_server']['log_dir'].start_with?('\\\\') ||
           node['arcgis']['notebook_server']['log_dir'].start_with?('/net/') }
  action :create
end

arcgis_notebooks_server 'Create ArcGIS Notebook Server site' do
  server_url node['arcgis']['notebook_server']['url']
  username node['arcgis']['notebook_server']['admin_username']
  password node['arcgis']['notebook_server']['admin_password']
  server_directories_root node['arcgis']['notebook_server']['directories_root']
  workspace node['arcgis']['notebook_server']['workspace']
  config_store_connection_string node['arcgis']['notebook_server']['config_store_connection_string']
  config_store_class_name node['arcgis']['notebook_server']['config_store_class_name']
  config_store_type node['arcgis']['notebook_server']['config_store_type']
  log_level node['arcgis']['notebook_server']['log_level']
  log_dir node['arcgis']['notebook_server']['log_dir']
  max_log_file_age node['arcgis']['notebook_server']['max_log_file_age']
  retries 5
  retry_delay 30
  action :create_site
end

arcgis_notebooks_server 'Set ArcGIS Notebook Server system properties' do
  server_url node['arcgis']['notebook_server']['url']
  username node['arcgis']['notebook_server']['admin_username']
  password node['arcgis']['notebook_server']['admin_password']
  system_properties node['arcgis']['notebook_server']['system_properties']
  retries 5
  retry_delay 30
  action :set_system_properties
end

include_recipe 'arcgis-notebooks::samples_data' if node['arcgis']['notebook_server']['install_samples_data']
