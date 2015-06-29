#
# Cookbook Name:: arcgis
# Recipe:: datastore
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

arcgis_datastore "Setup ArcGIS DataStore" do
  setup node['data_store']['setup']
  install_dir node['data_store']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  action :install
end

directory node['data_store']['data_dir'] do
  owner node['arcgis']['run_as_user']
  if node['platform'] != 'windows'
    group 'root'    
    mode '0755'
  end
  recursive true
  not_if {node['data_store']['data_dir'].start_with?("\\\\")}
  action :create
end

directory node['data_store']['backup_dir'] do
  owner node['arcgis']['run_as_user']
  if node['platform'] != 'windows'
    group 'root'    
    mode '0755'
  end
  recursive true
  not_if {node['data_store']['backup_dir'].start_with?("\\\\")}
  action :create
end

arcgis_datastore "Configure ArcGIS DataStore" do
  install_dir node['data_store']['install_dir']
  data_dir node['data_store']['data_dir']
  backup_dir node['data_store']['backup_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  server_url "https://" + node['server']['domain_name'] + ":6443/arcgis"
  username node['server']['admin_username']
  password node['server']['admin_password']
  action :configure
end