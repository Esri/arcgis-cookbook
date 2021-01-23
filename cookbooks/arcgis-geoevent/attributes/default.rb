#
# Cookbook Name:: arcgis-geoevent
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

include_attribute 'arcgis-repository'

default['arcgis']['geoevent'].tap do |geoevent|
  geoevent['authorization_file'] = node['arcgis']['server']['authorization_file']
  geoevent['authorization_file_version'] = node['arcgis']['server']['authorization_file_version']
  unless node['arcgis']['geoevent']['authorization_file'].nil?
    geoevent['cached_authorization_file'] = ::File.join(Chef::Config[:file_cache_path],
                                                        ::File.basename(node['arcgis']['geoevent']['authorization_file']))
  end
  geoevent['configure_autostart'] = true

  case
  when ['10.6', '10.6.1', '10.7', '10.7.1', '10.8', '10.8.1'].include?(node['arcgis']['version'])
    geoevent['ports'] = '6180,6143,4181,4182,4190,9191,9192,9193,9194,9220,9320,5565,5575,27271,27272,27273,2181,2182,2190'
    geoevent['configure_gateway_service'] = true
  when ['10.4', '10.4.1', '10.5', '10.5.1'].include?(node['arcgis']['version'])
    geoevent['ports'] = '6180,6143,9220,9320,5565,5575,27271,27272,27273'
    geoevent['configure_gateway_service'] = false
  end

  geoevent['setup_archive'] = ''

  case node['platform']
  when 'windows'
    geoevent['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                    'ArcGIS ' + node['arcgis']['version'],
                                    'ArcGISGeoEventServer', 'Setup.exe')
    geoevent['lp-setup'] = 'C:\\ArcGIS\\GeoEvent\\SetupFiles\\setup.msi'

    case node['arcgis']['version']
    when '10.8.1'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_1081_175242.exe').gsub('/', '\\')
      geoevent['product_code'] = '{C98F8E6F-A6D0-479A-B80E-C173996DD70B}'
    when '10.8'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_108_172924.exe').gsub('/', '\\')
      geoevent['product_code'] = '{10F38ED5-B9A1-4F0C-B8E2-06AD1365814C}'
    when '10.7.1'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_1071_169716.exe').gsub('/', '\\')
      geoevent['product_code'] = '{3AE4EE62-B5ED-45CB-8917-F761B9335F33}'
    when '10.7'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_107_167668.exe').gsub('/', '\\')
      geoevent['product_code'] = '{7430C9C3-7D96-429E-9F47-04938A1DC37E}'
    when '10.6.1'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_1061_163795.exe').gsub('/', '\\')
      geoevent['product_code'] = '{D0586C08-E589-4942-BC9B-E83B2E8B95C2}'
      Chef::Log.warn 'Unsupported ArcGIS GeoEvent Server version'
    when '10.6'
      geoevent['product_code'] = '{723742C8-6633-4C85-87AC-503507FE222B}'
      Chef::Log.warn 'Unsupported ArcGIS GeoEvent Server version'
    when '10.5.1'
      geoevent['product_code'] = '{F11BBE3B-B78F-4E5D-AE45-E3B29063335F}'
      Chef::Log.warn 'Unsupported ArcGIS GeoEvent Server version'
    when '10.5'
      geoevent['product_code'] = '{4375BD31-BD98-4166-84D9-E944D77103E8}'
      Chef::Log.warn 'Unsupported ArcGIS GeoEvent Server version'
    when '10.4.1'
      geoevent['product_code'] = '{D71379AF-A72B-4B10-A7BA-64BC6AF6841B}'
      Chef::Log.warn 'Unsupported ArcGIS GeoEvent Server version'
    when '10.4'
      geoevent['product_code'] = '{188191AE-5A83-49E8-88CB-1F1DB05F030D}'
      Chef::Log.warn 'Unsupported ArcGIS GeoEvent Server version'
    else
      Chef::Log.warn 'Unsupported ArcGIS GeoEvent Server version'
    end
  else # node['platform'] == 'linux'
    geoevent['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                    node['arcgis']['version'],
                                    'ArcGISGeoEventServer', 'Setup.sh')
    geoevent['lp-setup'] = '/arcgis/geo-event-cdLP/Language-Pack-Setup.sh'

    case node['arcgis']['version']
    when '10.8.1'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_1081_175325.tar.gz')
    when '10.8'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_108_173004.tar.gz')
    when '10.7.1'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_1071_169919.tar.gz')
    when '10.7'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_107_167732.tar.gz')
    when '10.6.1'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_1061_164069.tar.gz')
      Chef::Log.warn 'Unsupported ArcGIS GeoEvent Server version'
    else
      Chef::Log.warn 'Unsupported ArcGIS GeoEvent Server version'
    end
  end
end
