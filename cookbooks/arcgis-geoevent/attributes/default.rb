#
# Cookbook Name:: arcgis-geoevent
# Attributes:: default
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
default['arcgis']['geoevent']['authorization_file'] = node['arcgis']['server']['authorization_file']
default['arcgis']['geoevent']['authorization_file_version'] = node['arcgis']['server']['authorization_file_version']
unless node['arcgis']['geoevent']['authorization_file'].nil?
  default['arcgis']['geoevent']['cached_authorization_file'] = ::File.join(Chef::Config[:file_cache_path],
                                                                           ::File.basename(node['arcgis']['geoevent']['authorization_file']))
end
default['arcgis']['geoevent']['configure_autostart'] = true

case
when ['10.6'].include?(node['arcgis']['version'])
  default['arcgis']['geoevent']['ports'] = '6180,6143,4181,4182,4190,9191,9192,9193,9194,9220,9320,5565,5575,27271,27272,27273'
  default['arcgis']['geoevent']['configure_gateway_service'] = true
when ['10.4', '10.4.1', '10.5', '10.5.1'].include?(node['arcgis']['version'])
  default['arcgis']['geoevent']['ports'] = '6180,6143,9220,9320,5565,5575,27271,27272,27273'
  default['arcgis']['geoevent']['configure_gateway_service'] = false
end


case node['platform']
when 'windows'
  default['arcgis']['geoevent']['setup'] = 'C:\\ArcGIS\\GeoEvent\\setup.exe'
  default['arcgis']['geoevent']['lp-setup'] = 'C:\\ArcGIS\\GeoEvent\\SetupFiles\\setup.msi'

  case node['arcgis']['version']
  when '10.6'
    default['arcgis']['geoevent']['product_code'] = '{723742C8-6633-4C85-87AC-503507FE222B}'
  when '10.5.1'
    default['arcgis']['geoevent']['product_code'] = '{F11BBE3B-B78F-4E5D-AE45-E3B29063335F}'
  when '10.5'
    default['arcgis']['geoevent']['product_code'] = '{4375BD31-BD98-4166-84D9-E944D77103E8}'
  when '10.4.1'
    default['arcgis']['geoevent']['product_code'] = '{D71379AF-A72B-4B10-A7BA-64BC6AF6841B}'
  when '10.4'
    default['arcgis']['geoevent']['product_code'] = '{188191AE-5A83-49E8-88CB-1F1DB05F030D}'
  else
    throw 'Unsupported ArcGIS version'
  end
else # node['platform'] == 'linux'
  default['arcgis']['geoevent']['setup'] = '/arcgis/geo-event-cd/Setup.sh'
  default['arcgis']['geoevent']['lp-setup'] = '/arcgis/geo-event-cdLP/Language-Pack-Setup.sh'
end
