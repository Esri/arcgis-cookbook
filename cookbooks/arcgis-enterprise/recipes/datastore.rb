#
# Cookbook Name:: arcgis-enterprise
# Recipe:: datastore
#
# Copyright 2018 Esri
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

include_recipe 'arcgis-enterprise::install_datastore'

arcgis_enterprise_datastore 'Configure ArcGIS Data Store' do
  install_dir node['arcgis']['data_store']['install_dir']
  data_dir node['arcgis']['data_store']['data_dir']
  types node['arcgis']['data_store']['types']
  run_as_user node['arcgis']['run_as_user']
  server_url 'https://' + node['arcgis']['server']['domain_name'] + ':6443/arcgis'
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  retries 5
  retry_delay 60
  action :configure
end

arcgis_enterprise_datastore 'Change ArcGIS DataStore backup location' do
  install_dir node['arcgis']['data_store']['install_dir']
  backup_dir node['arcgis']['data_store']['backup_dir']
  run_as_user node['arcgis']['run_as_user']
  only_if { node['arcgis']['data_store']['types'].include? 'relational' }
  action :change_backup_location
end
