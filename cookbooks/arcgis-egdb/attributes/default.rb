#
# Cookbook Name:: arcgis-egdb
# Attributes:: default
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

include_attribute 'arcgis-enterprise'

default['arcgis']['egdb']['engine'] = nil
default['arcgis']['egdb']['endpoint'] = nil
default['arcgis']['egdb']['master_username'] = 'EsriRDSAdmin'
default['arcgis']['egdb']['master_password'] = nil

default['arcgis']['egdb']['db_username'] = 'sde'
default['arcgis']['egdb']['db_password'] = node['arcgis']['egdb']['master_password']

default['arcgis']['egdb']['keycodes'] = node['arcgis']['server']['keycodes']

# Folder for *.sde connection files created by Publishing GP tools
# The folder must be accessible for user account specified by node['arcgis']['run_as_user']
default['arcgis']['egdb']['connection_files_dir'] = ::File.join(
  node['arcgis']['misc']['scripts_dir'], 'connection_files')

# Use embedded PostgeSQL client from ArcGIS Data Store installed on ArcGIS Enterprise AMIs.
if node['platform'] == 'windows'
  default['arcgis']['egdb']['postgresbin'] = 'C:\Program Files\ArcGIS\DataStore\framework\runtime\pgsql\bin'
else
  default['arcgis']['egdb']['postgresbin'] = '/arcgis/datastore/framework/runtime/pgsql/bin'
end

default['arcgis']['egdb']['data_items'] = [{
  'database' => 'egdb',
  'data_item_path' => '/enterpriseDatabases/registeredDatabase',
  'connection_file' => ::File.join(node['arcgis']['egdb']['connection_files_dir'], 'RDS_egdb.sde'),
  'is_managed' => true,
  'connection_type' => 'shared'
}]
