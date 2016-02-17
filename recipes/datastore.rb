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

arcgis_datastore 'ArcGIS DataStore system requirements' do
  action :system
end

directory node['arcgis']['data_store']['data_dir'] do
  owner node['arcgis']['run_as_user']
  if node['platform'] != 'windows'
    group 'root'
    mode '0755'
  end
  recursive true
  action :create
end

directory node['arcgis']['data_store']['backup_dir'] do
  owner node['arcgis']['run_as_user']
  if node['platform'] != 'windows'
    group 'root'
    mode '0755'
  end
  recursive true
  not_if { node['arcgis']['data_store']['backup_dir'].start_with?('\\\\') ||
           node['arcgis']['data_store']['backup_dir'].start_with?('/net/') }
  action :create
end

arcgis_datastore 'Setup ArcGIS DataStore' do
  setup node['arcgis']['data_store']['setup']
  install_dir node['arcgis']['data_store']['install_dir']
  data_dir node['arcgis']['data_store']['data_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  action :install
end

arcgis_datastore 'Configure ArcGIS DataStore' do
  install_dir node['arcgis']['data_store']['install_dir']
  data_dir node['arcgis']['data_store']['data_dir']
  types node['arcgis']['data_store']['types']
  run_as_user node['arcgis']['run_as_user']
  server_url node['arcgis']['server']['private_url']
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  action :configure
end

arcgis_datastore 'Configure ArcGIS DataStore' do
  install_dir node['arcgis']['data_store']['install_dir']
  backup_dir node['arcgis']['data_store']['backup_dir']
  run_as_user node['arcgis']['run_as_user']
  only_if { node['arcgis']['data_store']['types'].include? 'relational' }
  action :change_backup_location
end
