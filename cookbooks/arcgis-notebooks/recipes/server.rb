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

arcgis_notebooks_server 'Authorize ArcGIS Notebook Server' do
  authorization_file node['arcgis']['notebook_server']['authorization_file']
  authorization_file_version node['arcgis']['notebook_server']['authorization_file_version']
  retries 2
  retry_delay 30
  notifies :stop, 'arcgis_notebooks_server[Stop ArcGIS Notebook Server]', :immediately
  action :authorize
end

# Restart ArcGIS Server
arcgis_notebooks_server 'Stop ArcGIS Notebook Server' do
  action :nothing
end

arcgis_notebooks_server 'Start ArcGIS Notebook Server' do
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

directory node['arcgis']['notebook_server']['workspace'] do
  owner node['arcgis']['run_as_user']
  recursive true
  only_if { node['platform'] == 'windows' }
  action :create
end

arcgis_notebooks_server 'Create ArcGIS Notebook Server site' do
  install_dir node['arcgis']['notebook_server']['install_dir']
  server_url node['arcgis']['notebook_server']['url']
  username node['arcgis']['notebook_server']['admin_username']
  password node['arcgis']['notebook_server']['admin_password']
  server_directories_root node['arcgis']['notebook_server']['directories_root']
  workspace node['arcgis']['notebook_server']['workspace']
  config_store_connection_string node['arcgis']['notebook_server']['config_store_connection_string']
  retries 5
  retry_delay 30
  action :create_site
end
