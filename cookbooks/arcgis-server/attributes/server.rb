#
# Cookbook Name:: arcgis-server
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
  server['admin_password'] = 'changeit'
  server['managed_database'] = ''
  server['replicated_database'] = ''
  server['keystore_file'] = ''
  server['keystore_password'] = ''
  server['cert_alias'] = node['arcgis']['server']['domain_name']
  server['system_properties'] = {}
  server['log_level'] = 'WARNING'
  server['max_log_file_age'] = 90
  server['is_hosting'] = true
  server['configure_autostart'] = true
  server['install_system_requirements'] = true
  server['use_join_site_tool'] = false

  unless node['arcgis']['server']['authorization_file'].nil?
    server['cached_authorization_file'] = ::File.join(Chef::Config[:file_cache_path],
                                                      ::File.basename(node['arcgis']['server']['authorization_file']))
  end

  # authorization_file_version must be <major>.<minor> ('10.4.1' -> '10.4')
  server['authorization_file_version'] = node['arcgis']['version'].to_f.to_s

  server['publisher_username'] = node['arcgis']['server']['admin_username']
  server['publisher_password'] = node['arcgis']['server']['admin_password']

  server['authorization_retries'] = 10

  case node['platform']
  when 'windows'
    server['authorization_tool'] = ENV['ProgramW6432'] + '\\Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe'
    server['authorization_file'] = ''
    server['keycodes'] = ENV['ProgramW6432'] + "\\ESRI\\License#{node['arcgis']['server']['authorization_file_version']}\\sysgen\\keycodes"
    server['setup'] = 'C:\\Temp\\ArcGISServer\\Setup.exe'
    server['lp-setup'] = 'C:\\Temp\\ArcGISServer\\SetupFile\\Setup.msi'
    server['install_dir'] = ENV['ProgramW6432'] + '\\ArcGIS\\Server'
    server['local_directories_root'] = 'C:\\arcgisserver'
    server['directories_root'] = node['arcgis']['server']['local_directories_root']
    server['log_dir'] = ::File.join(node['arcgis']['server']['local_directories_root'], 'logs')
    server['config_store_type'] = 'FILESYSTEM'
    server['config_store_connection_string'] = ::File.join(node['arcgis']['server']['directories_root'], 'config-store')
    server['config_store_connection_secret'] = ''

    case node['arcgis']['version']
    when '10.5'
      server['product_code'] = '{CD87013B-6559-4804-89F6-B6F1A7B31CBC}'
    when '10.4.1'
      server['product_code'] = '{88A617EF-89AC-418E-92E1-926908C4D50F}'
    when '10.4'
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
    server['setup'] = '/tmp/server-cd/Setup'
    server['lp-setup'] = '/tmp/serverLP-cd/Setup'
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
