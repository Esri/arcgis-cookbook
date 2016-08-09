#
# Cookbook Name:: arcgis-server
# Attributes:: datastore
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

default['arcgis']['data_store'].tap do |data_store|

  case ENV['arcgis_cloud_platform']
  when 'aws'
    data_store['preferredidentifier'] = 'ip'
  else
    data_store['preferredidentifier'] = 'hostname'
  end

  data_store['types'] = 'tileCache,relational'
  data_store['configure_autostart'] = true
  data_store['install_system_requirements'] = true

  case node['platform']
  when 'windows'
    data_store['setup'] = 'C:\\Temp\\ArcGISDataStore\\Setup.exe'
    data_store['lp-setup'] = 'C:\\Temp\\ArcGISDataStore\\SetupFile\\Setup.msi'
    data_store['install_dir'] = ENV['ProgramW6432'] + '\\ArcGIS\\DataStore'
    data_store['data_dir'] = 'C:\\arcgisdatastore'
    data_store['local_backup_dir'] = node['arcgis']['data_store']['data_dir'] + '\\backup'
    data_store['backup_dir'] = node['arcgis']['data_store']['local_backup_dir']

    case node['arcgis']['version']
    when '10.5'
      data_store['product_code'] = '{5EA81114-6FA7-4B4C-BD72-D1C882088AAC}'
    when '10.4.1'
      data_store['product_code'] = '{A944E0A7-D268-41CA-B96E-8434457B051B}'
    when '10.4'
      data_store['product_code'] = '{C351BC6D-BF25-487D-99AB-C963D590A8E8}'
    else
      throw 'Unsupported ArcGIS version'
    end
  else # node['platform'] == 'linux'
    data_store['setup'] = '/tmp/data-store-cd/Setup'
    data_store['install_dir'] = '/'
    data_store['install_subdir'] = 'arcgis/datastore'
    data_store['start_tool'] = ::File.join(node['arcgis']['data_store']['install_dir'],
                                           node['arcgis']['data_store']['install_subdir'],
                                           '/startdatastore.sh')
    data_store['stop_tool'] = ::File.join(node['arcgis']['data_store']['install_dir'],
                                          node['arcgis']['data_store']['install_subdir'],
                                          '/stopdatastore.sh')
    data_store['data_dir'] = ::File.join(node['arcgis']['data_store']['install_dir'],
                                         node['arcgis']['data_store']['install_subdir'],
                                         '/usr/arcgisdatastore')
    data_store['local_backup_dir'] = node['arcgis']['data_store']['data_dir'] + '/backup'
    data_store['backup_dir'] = node['arcgis']['data_store']['local_backup_dir']
  end

end
