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

case node['platform']
when 'windows'
  default['arcgis']['geoevent']['setup'] = 'C:\\ArcGIS\\GeoEvent\\setup.exe'
  default['arcgis']['geoevent']['lp-setup'] = 'C:\\ArcGIS\\GeoEvent\\SetupFiles\\setup.msi'

  case node['arcgis']['version']
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
