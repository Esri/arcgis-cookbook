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

arcgis_server "Setup ArcGIS for Server" do
  setup node['server']['setup']
  install_dir node['server']['install_dir']
  python_dir node['python']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  action :install
end

arcgis_server "Authorize ArcGIS for Server" do
  authorization_file node['server']['authorization_file']
  authorization_file_version node['server']['authorization_file_version']
  action :authorize
end

directory node['server']['directories_root'] do
  owner node['arcgis']['run_as_user']
  if node['platform'] != 'windows'
    group 'root'    
    mode '0755'
  end
  recursive true
  not_if { node['server']['directories_root'].start_with?("\\\\") }
  action :create
end

if node['server']['primary_server_url'].nil?
  #Create Site
  arcgis_server "Create ArcGIS for Server Site" do
    server_url node['server']['local_url']
    username node['server']['admin_username']
    password node['server']['admin_password']
    server_directories_root node['server']['directories_root']
    retries 5
    retry_delay 30
    action :create_site
  end
  
  arcgis_server "Enable SSL on ArcGIS Server Site" do
    server_url node['server']['local_url']
    username node['server']['admin_username']
    password node['server']['admin_password']
    retries 5
    retry_delay 30
    action :enable_ssl
  end
else
  #Join Site
  arcgis_server "Join ArcGIS for Server Site" do
    server_url node['server']['local_url']
    username node['server']['admin_username']
    password node['server']['admin_password']
    primary_server_url node['server']['primary_server_url']
    retries 10
    retry_delay 30
    action :join_site
  end
  
  arcgis_server "Add machine to default cluster" do
    server_url node['server']['local_url']
    username node['server']['admin_username']
    password node['server']['admin_password']
    cluster 'default'
    retries 10
    retry_delay 30
    action :join_cluster
  end
end