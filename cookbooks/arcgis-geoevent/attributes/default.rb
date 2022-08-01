#
# Cookbook Name:: arcgis-geoevent
# Attributes:: default
#
# Copyright 2022 Esri
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

  geoevent['ports'] = '6180,6143,4181,4182,4190,9191,9192,9193,9194,9220,9320,5565,5575,27271,27272,27273,2181,2182,2190'

  geoevent['setup_archive'] = ''

  geoevent['patches'] = []

  geoevent['setup_options'] = ''

  case node['platform']
  when 'windows'
    geoevent['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                    'ArcGIS ' + node['arcgis']['version'],
                                    'ArcGISGeoEventServer', 'Setup.exe')
    geoevent['lp-setup'] = 'C:\\ArcGIS\\GeoEvent\\SetupFiles\\setup.msi'

    case node['arcgis']['version']
    when '11.0'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_110_182914.exe').gsub('/', '\\')
      geoevent['product_code'] = '{98B0A1CC-5CE4-4311-85DD-46ABD08232C5}'
      geoevent['patch_registry'] ='SOFTWARE\ESRI\GeoEvent11.0\Server\Updates'
    when '10.9.1'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_1091_180081.exe').gsub('/', '\\')
      geoevent['product_code'] = '{F5C3D729-0B74-419D-9154-D05C63606A94}'
      geoevent['patch_registry'] ='SOFTWARE\ESRI\GeoEvent10.9\Server\Updates'
    when '10.9'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_109_177813.exe').gsub('/', '\\')
      geoevent['product_code'] = '{B73748C3-DD75-4376-B4DA-D52C59121A10}'
      geoevent['patch_registry'] ='SOFTWARE\ESRI\GeoEvent10.9\Server\Updates'      
    when '10.8.1'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_1081_175242.exe').gsub('/', '\\')
      geoevent['product_code'] = '{C98F8E6F-A6D0-479A-B80E-C173996DD70B}'
      geoevent['patch_registry'] ='SOFTWARE\ESRI\GeoEvent10.8\Server\Updates'
    when '10.8'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_108_172924.exe').gsub('/', '\\')
      geoevent['product_code'] = '{10F38ED5-B9A1-4F0C-B8E2-06AD1365814C}'
      geoevent['patch_registry'] ='SOFTWARE\ESRI\GeoEvent10.8\Server\Updates'
    else
      Chef::Log.warn 'Unsupported ArcGIS GeoEvent Server version'
    end
  else # node['platform'] == 'linux'
    geoevent['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                    node['arcgis']['version'],
                                    'ArcGISGeoEventServer', 'Setup.sh')
    geoevent['lp-setup'] = '/arcgis/geo-event-cdLP/Language-Pack-Setup.sh'

    case node['arcgis']['version']
    when '11.0'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_110_183031.tar.gz')
    when '10.9.1'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_1091_180218.tar.gz')
    when '10.9'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_109_177900.tar.gz')
    when '10.8.1'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_1081_175325.tar.gz')
    when '10.8'
      geoevent['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_GeoEvent_Server_108_173004.tar.gz')
    else
      Chef::Log.warn 'Unsupported ArcGIS GeoEvent Server version'
    end

    if node['arcgis']['server']['install_dir'].nil?
      server_install_dir = default['arcgis']['server']['install_dir']
    else
      server_install_dir = node['arcgis']['server']['install_dir']
    end

    if node['arcgis']['server']['install_subdir'].nil?
      server_install_subdir = default['arcgis']['server']['install_subdir']
    else
      server_install_subdir = node['arcgis']['server']['install_subdir']
    end

    geoevent['patch_log'] = ::File.join(server_install_dir,
                                        server_install_subdir,
                                        'GeoEvent', '.ESRI_GES_PATCH_LOG')
  end
end
