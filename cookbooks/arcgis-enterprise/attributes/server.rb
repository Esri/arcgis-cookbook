#
# Cookbook Name:: arcgis-enterprise
# Attributes:: server
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

default['arcgis']['server'].tap do |server|

  server['wa_name'] = 'server'

  if node['fqdn'].nil? || ENV['arcgis_cloud_platform'] == 'aws'
    server['domain_name'] = node['ipaddress']
    server['url'] = 'https://' + node['ipaddress'] + ':6443/arcgis'
    server['wa_url'] = 'https://' + node['ipaddress'] + '/' + node['arcgis']['server']['wa_name']
  else
    server['domain_name'] = node['fqdn']
    server['url'] = 'https://' + node['fqdn'] + ':6443/arcgis'
    server['wa_url'] = 'https://' + node['fqdn'] + '/' + node['arcgis']['server']['wa_name']
  end

  server['private_url'] = 'https://' + node['arcgis']['server']['domain_name'] + ':6443/arcgis'
  server['web_context_url'] = 'https://' + node['arcgis']['server']['domain_name'] + '/' + node['arcgis']['server']['wa_name']
  server['admin_username'] = 'admin'
  if ENV['ARCGIS_SERVER_ADMIN_PASSWORD'].nil?
    server['admin_password'] = 'changeit'
  else
    server['admin_password'] = ENV['ARCGIS_SERVER_ADMIN_PASSWORD']
  end
  server['managed_database'] = ''
  server['replicated_database'] = ''
  server['keystore_file'] = ''
  if ENV['ARCGIS_SERVER_KEYSTORE_PASSWORD'].nil?
    server['keystore_password'] = ''
  else
    server['keystore_password'] = ENV['ARCGIS_SERVER_KEYSTORE_PASSWORD']
  end
  server['cert_alias'] = node['arcgis']['server']['domain_name']
  server['system_properties'] = {}
  server['log_level'] = 'WARNING'
  server['max_log_file_age'] = 90
  server['is_hosting'] = true
  server['configure_autostart'] = true
  server['install_system_requirements'] = true
  server['use_join_site_tool'] = false
  server['soc_max_heap_size'] = 64

  unless node['arcgis']['server']['authorization_file'].nil?
    server['cached_authorization_file'] = ::File.join(Chef::Config[:file_cache_path],
                                                      ::File.basename(node['arcgis']['server']['authorization_file']))
  end

  # authorization_file_version must be <major>.<minor> ('10.4.1' -> '10.4')
  server['authorization_file_version'] = node['arcgis']['version'].to_f.to_s

  server['publisher_username'] = node['arcgis']['server']['admin_username']
  server['publisher_password'] = node['arcgis']['server']['admin_password']

  server['authorization_retries'] = 10

  server['security']['user_store_config'] = {'type' => 'BUILTIN', 'properties' => {}}
  server['security']['role_store_config'] = {'type' => 'BUILTIN', 'properties' => {}}
  server['security']['privileges'] = {'PUBLISH' => [], 'ADMINISTER' => []}

  case node['platform']
  when 'windows'
    server['authorization_tool'] = ENV['ProgramW6432'] + '\\Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe'
    server['authorization_file'] = ''
    server['keycodes'] = ENV['ProgramW6432'] + "\\ESRI\\License#{node['arcgis']['server']['authorization_file_version']}\\sysgen\\keycodes"
    server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  'ArcGIS ' + node['arcgis']['version'],
                                  'ArcGISServer', 'Setup.exe')
    server['lp-setup'] = node['arcgis']['server']['setup']
    server['install_dir'] = ENV['ProgramW6432'] + '\\ArcGIS\\Server'

    server['local_directories_root'] = 'C:\\arcgisserver'

    if node['arcgis']['server']['local_directories_root'].nil?
      server['directories_root'] = server['local_directories_root']
    else
      server['directories_root'] = node['arcgis']['server']['local_directories_root']
    end

    if node['arcgis']['server']['local_directories_root'].nil?
      server['log_dir'] = ::File.join(server['local_directories_root'], 'logs')
    else
      server['log_dir'] = ::File.join(node['arcgis']['server']['local_directories_root'], 'logs') 
    end

    server['config_store_type'] = 'FILESYSTEM'
    if node['arcgis']['server']['directories_root'].nil?
      server['config_store_connection_string'] = ::File.join(server['directories_root'], 'config-store')
    else
      server['config_store_connection_string'] = ::File.join(node['arcgis']['server']['directories_root'], 'config-store')
    end
    server['config_store_connection_secret'] = ''

    case node['arcgis']['version']
    when '10.6'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Windows_106_159940.exe')
      server['product_code'] = '{07606F78-D997-43AE-A9DC-0738D91E8D02}'
    when '10.5.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Windows_1051_156124.exe')
      server['product_code'] = '{40CC6E89-93A4-4D87-A3FB-11413C218D2C}'
    when '10.5'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Windows_105_154004.exe')
      server['product_code'] = '{CD87013B-6559-4804-89F6-B6F1A7B31CBC}'
    when '10.4.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_for_Server_Windows_1041_151921.exe')
      server['product_code'] = '{88A617EF-89AC-418E-92E1-926908C4D50F}'
    when '10.4'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_for_Server_Windows_104_149433.exe')
      server['product_code'] = '{687897C7-4795-4B17-8AD0-CB8C364778AD}'
    else
      throw 'Unsupported ArcGIS version'
    end
  else # node['platform'] == 'linux'
    server['install_dir'] = '/'
    server['install_subdir'] = 'arcgis/server'
    server['start_tool'] = ::File.join(node['arcgis']['server']['install_dir'],
                                       node['arcgis']['server']['install_subdir'],
                                       '/startserver.sh')
    server['stop_tool'] = ::File.join(node['arcgis']['server']['install_dir'],
                                      node['arcgis']['server']['install_subdir'],
                                      '/stopserver.sh')
    server['authorization_tool'] = ::File.join(node['arcgis']['server']['install_dir'],
                                               node['arcgis']['server']['install_subdir'],
                                               '/tools/authorizeSoftware')
    server['authorization_file'] = ''
    server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  node['arcgis']['version'],
                                  'ArcGISServer', 'Setup')
    server['lp-setup'] = node['arcgis']['server']['setup']

    case node['arcgis']['version']
    when '10.6'
        server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Server_Linux_106_159989.tar.gz')
    when '10.5.1'
        server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Server_Linux_1051_156429.tar.gz')
    when '10.5'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Linux_105_154052.tar.gz')
    when '10.4.1'                                            
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_for_Server_Linux_1041_151978.tar.gz')
    when '10.4'                                            
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_for_Server_Linux_104_149446.tar.gz')
    else
      throw 'Unsupported ArcGIS version'
    end

    server['local_directories_root'] = ::File.join(node['arcgis']['server']['install_dir'],
                                                   node['arcgis']['server']['install_subdir'],
                                                   'usr')
    server['directories_root'] = node['arcgis']['server']['local_directories_root']
    server['log_dir'] = ::File.join(node['arcgis']['server']['local_directories_root'], 'logs')
    server['config_store_type'] = 'FILESYSTEM'
    server['config_store_connection_string'] = ::File.join(node['arcgis']['server']['directories_root'], "config-store")
    server['config_store_connection_secret'] = nil
  end
end
