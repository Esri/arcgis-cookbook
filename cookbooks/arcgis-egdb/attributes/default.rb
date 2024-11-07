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
  default['arcgis']['egdb']['sqlcmdbin'] = 'C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn'
else
  default['arcgis']['egdb']['postgresbin'] = '/arcgis/datastore/framework/runtime/pgsql/bin'
end

default['arcgis']['egdb']['data_items'] = [{
  'database' => 'egdb',
  'data_item_path' => '/enterpriseDatabases/registeredDatabase',
  'connection_file' => ::File.join(node['arcgis']['egdb']['connection_files_dir'], 'RDS_egdb.sde'),
  'is_managed' => false,
  'connection_type' => 'shared'
}]

# Microsoft Command Line Utilities 15 for SQL Server fails to recognize pre-requisite ODBC 17 
# The workaround is to install ODBC 13 first

default['arcgis']['egdb']['vc_redist_url'] = 'https://download.visualstudio.microsoft.com/download/pr/11100230/15ccb3f02745c7b206ad10373cbca89b/VC_redist.x64.exe'
default['arcgis']['egdb']['vc_redist_path'] = ::File.join(node['arcgis']['repository']['setups'],
                                                              'VC_redist.x64.exe').gsub('/', '\\')

default['arcgis']['egdb']['msodbcsql13_msi_url'] = 'https://download.microsoft.com/download/D/5/E/D5EEF288-A277-45C8-855B-8E2CB7E25B96/x64/msodbcsql.msi'
default['arcgis']['egdb']['msodbcsql13_msi_path'] = ::File.join(node['arcgis']['repository']['setups'],
                                                              'msodbcsql13.msi').gsub('/', '\\')

default['arcgis']['egdb']['msodbcsql17_msi_url'] = 'https://download.microsoft.com/download/E/6/B/E6BFDC7A-5BCD-4C51-9912-635646DA801E/en-US/17.5.2.1/x64/msodbcsql.msi'
default['arcgis']['egdb']['msodbcsql17_msi_path'] = ::File.join(node['arcgis']['repository']['setups'],
                                                              'msodbcsql17.msi').gsub('/', '\\')

default['arcgis']['egdb']['mssqlcmdlnutils_msi_url'] = 'https://download.microsoft.com/download/4/C/C/4CC1A229-3C56-4A7F-A3BA-F903C73E5895/EN/x64/MsSqlCmdLnUtils.msi'
default['arcgis']['egdb']['mssqlcmdlnutils_msi_path'] = ::File.join(node['arcgis']['repository']['setups'],
                                                              'msodbcsql.msi').gsub('/', '\\')
                                                              