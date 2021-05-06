#
# Cookbook Name:: arcgis-mission
# Attributes:: default
#
# Copyright 2020 Esri
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

default['arcgis']['mission_server'].tap do |mission_server|

  mission_server['wa_name'] = 'mission'

  if node['fqdn'].nil? || node['arcgis']['configure_cloud_settings']
    mission_server['url'] = "https://#{node['ipaddress']}:20443/arcgis"
    mission_server['wa_url'] = "https://#{node['ipaddress']}/#{node['arcgis']['mission_server']['wa_name']}"
    mission_server['domain_name'] = node['ipaddress']
    mission_server['hostname'] = node['ipaddress'] 
  else
    mission_server['url'] = "https://#{node['fqdn']}:20443/arcgis"
    mission_server['wa_url'] = "https://#{node['fqdn']}/#{node['arcgis']['mission_server']['wa_name']}"
    mission_server['domain_name'] = node['fqdn']
    mission_server['hostname'] = '' # Use the default server machine hostname 
  end

  mission_server['private_url'] = "https://#{node['arcgis']['mission_server']['domain_name']}:20443/arcgis"
  mission_server['web_context_url'] = "https://#{node['arcgis']['mission_server']['domain_name']}/#{node['arcgis']['mission_server']['wa_name']}"

  mission_server['ports'] = '20443,20300,20301,20302,20158,20159,20160'
  mission_server['authorization_file'] = node['arcgis']['server']['authorization_file']
  mission_server['authorization_file_version'] = node['arcgis']['server']['authorization_file_version']
  mission_server['configure_autostart'] = true
  mission_server['install_system_requirements'] = true

  mission_server['setup_archive'] = ''

  mission_server['admin_username'] = 'siteadmin'
  if ENV['ARCGIS_MISSION_SERVER_ADMIN_PASSWORD'].nil?
    mission_server['admin_password'] = 'change.it'
  else
    mission_server['admin_password'] = ENV['ARCGIS_MISSION_SERVER_ADMIN_PASSWORD']
  end

  mission_server['config_store_type'] = 'FILESYSTEM'
  mission_server['config_store_class_name'] = case node['arcgis']['mission_server']['config_store_type']
                                              when 'AMAZON'
                                                'com.esri.arcgis.carbon.persistence.impl.amazon.AmazonConfigPersistence'
                                              when 'AZURE'
                                                'com.esri.arcgis.carbon.persistence.impl.azure.AzureConfigPersistence'
                                              else
                                                'com.esri.arcgis.carbon.persistence.impl.filesystem.FSConfigPersistence'
                                              end

  mission_server['log_level'] = 'WARNING'
  mission_server['max_log_file_age'] = 90

  mission_server['system_properties'] = {}

  case node['platform']
  when 'windows'
    mission_server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                           'ArcGIS ' + node['arcgis']['version'],
                                           'MissionServer', 'Setup.exe')
    mission_server['install_dir'] = ::File.join(ENV['ProgramW6432'], 'ArcGIS\\Mission').gsub('/', '\\')
    mission_server['install_subdir'] = ''
    mission_server['authorization_tool'] = ::File.join(node['arcgis']['mission_server']['install_dir'],
      'bin\\SoftwareAuthorization.exe').gsub('/', '\\')
    mission_server['keycodes'] = ::File.join(ENV['ProgramW6432'],
      "ESRI\\License#{node['arcgis']['mission_server']['authorization_file_version']}\\sysgen\\keycodes").gsub('/', '\\')

    mission_server['directories_root'] = 'C:\\arcgismissionserver\\directories'
    mission_server['config_store_connection_string'] = 'C:\\arcgismissionserver\\config-store'
    mission_server['log_dir'] = 'C:\\arcgismissionserver\\logs'

    case node['arcgis']['version']
    when '10.9'
      mission_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_Mission_Server_Windows_109_177824.exe').gsub('/', '\\')
      mission_server['product_code'] = '{94280A6F-6501-42CE-A627-FCE20B01A9D7}'
    when '10.8.1'
      mission_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_Mission_Server_Windows_1081_175253.exe').gsub('/', '\\')
      mission_server['product_code'] = '{26F574C6-C9F8-487C-977A-A906AAA60136}'
    when '10.8'
      mission_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_Mission_Server_Windows_108_172945.exe').gsub('/', '\\')
      mission_server['product_code'] = '{A1A58B32-2ADF-4EAD-AC84-BE97318CA569}'
    else
      Chef::Log.warn 'Unsupported ArcGIS Mission Server version'
    end
  else # node['platform'] == 'linux'
    mission_server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                           node['arcgis']['version'],
                                           'MissionServer', 'Setup')
    mission_server['install_dir'] = "/home/#{node['arcgis']['run_as_user']}"
    mission_server['install_subdir'] = node['arcgis']['mission_server']['install_dir'].end_with?('/arcgis') ?
                                        'mission' : 'arcgis/mission'

    if node['arcgis']['mission_server']['install_dir'].nil?
      mission_server_install_dir = mission_server['install_dir']
    else
      mission_server_install_dir = node['arcgis']['mission_server']['install_dir']
    end

    if node['arcgis']['mission_server']['install_subdir'].nil?
      mission_server_install_subdir = mission_server['install_subdir']
    else
      mission_server_install_subdir = node['arcgis']['mission_server']['install_subdir']
    end

    mission_server['authorization_tool'] = ::File.join(mission_server_install_dir,
                                                       mission_server_install_subdir,
                                                       '/tools/authorizeSoftware')

    mission_server['directories_root'] = ::File.join(mission_server_install_dir,
                                                     mission_server_install_subdir,
                                                     'usr', 'directories')

    mission_server['config_store_connection_string'] = ::File.join(mission_server_install_dir,
                                                                   mission_server_install_subdir,
                                                                   'usr', 'config-store')

    mission_server['log_dir'] = ::File.join(mission_server_install_dir,
                                            mission_server_install_subdir,
                                            'usr', 'logs')

    case node['arcgis']['version']
    when '10.9'
      mission_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_Mission_Server_Linux_109_177909.tar.gz')
    when '10.8.1'
      mission_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_Mission_Server_Linux_1081_175334.tar.gz')
    when '10.8'
      mission_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_Mission_Server_Linux_108_173013.tar.gz')
    else
      Chef::Log.warn 'Unsupported ArcGIS Mission Server version'
    end
  end
end
