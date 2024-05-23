#
# Cookbook Name:: arcgis-enterprise
# Recipe:: datastore
#
# Copyright 2024 Esri
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

arcgis_enterprise_datastore 'Start ArcGIS Data Store' do
  action :start
end

arcgis_enterprise_datastore 'Configure ArcGIS Data Store' do
  install_dir node['arcgis']['data_store']['install_dir']
  data_dir node['arcgis']['data_store']['data_dir']
  types node['arcgis']['data_store']['types']
  mode node['arcgis']['data_store']['mode']
  roles node['arcgis']['data_store']['roles']
  run_as_user node['arcgis']['run_as_user']
  server_url node['arcgis']['server']['url']
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  retries 5
  retry_delay 60
  action :configure
end

node['arcgis']['data_store']['types'].split(',').each do |type|
  store_type = type.downcase.strip

  if !node['arcgis']['data_store'][store_type].nil?
    store_type_backup_type = node['arcgis']['data_store'][store_type]['backup_type']
    store_type_backup_location = node['arcgis']['data_store'][store_type]['backup_location'] 

    # Create Data Store backup dir if the backup type is 'fs' (file system) and
    # the directory is not on a file share. 
    directory store_type_backup_location do
      owner node['arcgis']['run_as_user']
      mode '0700' if node['platform'] != 'windows'
      recursive true
      only_if { store_type_backup_type == 'fs' }
      not_if { store_type_backup_location.start_with?('\\\\') ||
               store_type_backup_location.start_with?('/net/') }
      action :create
    end

    arcgis_enterprise_datastore "Configure ArcGIS Data Store #{store_type} backup location" do
      install_dir node['arcgis']['data_store']['install_dir']
      run_as_user node['arcgis']['run_as_user']
      store store_type
      backup_type store_type_backup_type
      backup_location store_type_backup_location
      only_if { store_type_backup_type != 'none' }
      action :configure_backup_location
    end
  end
end
