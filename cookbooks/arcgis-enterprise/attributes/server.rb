#
# Cookbook Name:: arcgis-enterprise
# Attributes:: server
#
# Copyright 2018 Esri
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

  server_wa_name = 'server'
  server['wa_name'] = server_wa_name

  unless node['arcgis']['server']['wa_name'].nil?
    server_wa_name = node['arcgis']['server']['wa_name']
  end

  if node['fqdn'].nil? || node['arcgis']['configure_cloud_settings']
    server_domain_name = node['ipaddress']
    server['domain_name'] = server_domain_name
    server['url'] = "https://#{node['ipaddress']}:6443/arcgis"
    server['wa_url'] = "https://#{node['ipaddress']}/#{server_wa_name}"
  else
    server_domain_name = node['fqdn']
    server['domain_name'] = server_domain_name
    server['url'] = "https://#{node['fqdn']}:6443/arcgis"
    server['wa_url'] = "https://#{node['fqdn']}/#{server_wa_name}"
  end

  unless node['arcgis']['server']['domain_name'].nil?
    server_domain_name = node['arcgis']['server']['domain_name']
  end

  server['hostname'] = '' # Use the default server machine hostname 
  server['private_url'] = "https://#{server_domain_name}:6443/arcgis"
  server['web_context_url'] = "https://#{server_domain_name}/#{server_wa_name}"
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
  server['cert_alias'] = server_domain_name
  server['system_properties'] = {}
  server['log_level'] = 'WARNING'
  server['max_log_file_age'] = 90
  server['is_hosting'] = true
  server['configure_autostart'] = true
  server['install_system_requirements'] = true
  server['use_join_site_tool'] = false
  server['soc_max_heap_size'] = 64
  server['protocol'] = 'HTTPS'
  server['authentication_mode'] = 'ARCGIS_TOKEN'
  server['authentication_tier'] = 'GIS_SERVER'
  server['hsts_enabled'] = false
  server['virtual_dirs_security_enabled'] = false
  server['allow_direct_access'] = true

  # hash of environment variables to pass to the install command.
  # e.g. server['install_environment'] = { 'IATEMPDIR' => /var/tmp' }
  server['install_environment'] = nil

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
  server['setup_archive'] = ''
  server['product_code'] = ''

  case node['platform']
  when 'windows'
    server['authorization_tool'] = ::File.join(ENV['ProgramW6432'],
                                               'Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe').gsub('/', '\\')
    server['authorization_file'] = ''
    server['keycodes'] = ::File.join(ENV['ProgramW6432'],
                                     "ESRI\\License#{node['arcgis']['server']['authorization_file_version']}\\sysgen\\keycodes").gsub('/', '\\')
    server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  "ArcGIS #{node['arcgis']['version']}",
                                  'ArcGISServer', 'Setup.exe').gsub('/', '\\')
    server['lp-setup'] = node['arcgis']['server']['setup']
    server['install_dir'] = ::File.join(ENV['ProgramW6432'], 'ArcGIS\\Server').gsub('/', '\\')
    server['install_subdir'] = ''

    server['local_directories_root'] = 'C:\\arcgisserver'

    case node['arcgis']['version']
    when '10.8'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Windows_108_172859.exe').gsub('/', '\\')
      server['product_code'] = '{458BF5FF-2DF8-426B-AEBC-BE4C47DB6B54}'
      default['arcgis']['python']['runtime_environment'] = File.join(node['arcgis']['python']['install_dir'], 
                                                                     "ArcGISx6410.8").gsub('/', '\\')
    when '10.7.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Windows_1071_169677.exe').gsub('/', '\\')
      server['product_code'] = '{08E03E6F-95D3-4D33-A171-E0DC996E08E3}'
      default['arcgis']['python']['runtime_environment'] = File.join(node['arcgis']['python']['install_dir'], 
                                                                     "ArcGISx6410.7").gsub('/', '\\')
    when '10.7'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Windows_107_167621.exe').gsub('/', '\\')
      server['product_code'] = '{98D5572E-C435-4841-A747-B4C72A8F76BB}'
      default['arcgis']['python']['runtime_environment'] = File.join(node['arcgis']['python']['install_dir'], 
                                                                     "ArcGISx6410.7").gsub('/', '\\')
    when '10.6.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Windows_1061_163968.exe').gsub('/', '\\')
      server['product_code'] = '{F62B418D-E9E4-41CE-9E02-167BE4276105}'
      default['arcgis']['python']['runtime_environment'] = File.join(node['arcgis']['python']['install_dir'], 
                                                                     "ArcGISx6410.6").gsub('/', '\\')
      Chef::Log.warn "Unsupported ArcGIS Server version '#{node['arcgis']['version']}'."
    when '10.6'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Windows_106_159940.exe').gsub('/', '\\')
      server['product_code'] = '{07606F78-D997-43AE-A9DC-0738D91E8D02}'
      default['arcgis']['python']['runtime_environment'] = File.join(node['arcgis']['python']['install_dir'],
                                                                     "ArcGISx6410.6").gsub('/', '\\')
      Chef::Log.warn "Unsupported ArcGIS Server version '#{node['arcgis']['version']}'."
    when '10.5.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Windows_1051_156124.exe').gsub('/', '\\')
      server['product_code'] = '{40CC6E89-93A4-4D87-A3FB-11413C218D2C}'
      default['arcgis']['python']['runtime_environment'] = File.join(node['arcgis']['python']['install_dir'],
                                                                     "ArcGISx6410.5").gsub('/', '\\')
      Chef::Log.warn "Unsupported ArcGIS Server version '#{node['arcgis']['version']}'."
    when '10.5'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Windows_105_154004.exe').gsub('/', '\\')
      server['product_code'] = '{CD87013B-6559-4804-89F6-B6F1A7B31CBC}'
      default['arcgis']['python']['runtime_environment'] = File.join(node['arcgis']['python']['install_dir'],
                                                                     "ArcGISx6410.5").gsub('/', '\\')
      Chef::Log.warn "Unsupported ArcGIS Server version '#{node['arcgis']['version']}'."                                                                     
    when '10.4.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_for_Server_Windows_1041_151921.exe').gsub('/', '\\')
      server['product_code'] = '{88A617EF-89AC-418E-92E1-926908C4D50F}'
      default['arcgis']['python']['runtime_environment'] = File.join(node['arcgis']['python']['install_dir'],
                                                                     "ArcGISx6410.4").gsub('/', '\\')
      Chef::Log.warn "Unsupported ArcGIS Server version '#{node['arcgis']['version']}'."
    when '10.4'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_for_Server_Windows_104_149433.exe').gsub('/', '\\')
      server['product_code'] = '{687897C7-4795-4B17-8AD0-CB8C364778AD}'
      default['arcgis']['python']['runtime_environment'] = File.join(node['arcgis']['python']['install_dir'], 
                                                                     "ArcGISx6410.4").gsub('/', '\\')
      Chef::Log.warn "Unsupported ArcGIS Server version '#{node['arcgis']['version']}'."
    else
      Chef::Log.warn "Unsupported ArcGIS Server version '#{node['arcgis']['version']}'."
    end
  else # node['platform'] == 'linux'
    server['install_dir'] = '/'
    server['install_subdir'] = 'arcgis/server'

    if node['arcgis']['server']['install_dir'].nil?
      server_install_dir = server['install_dir']
    else
      server_install_dir = node['arcgis']['server']['install_dir']
    end

    if node['arcgis']['server']['install_subdir'].nil?
      server_install_subdir = server['install_subdir']
    else
      server_install_subdir = node['arcgis']['server']['install_subdir']
    end

    server['start_tool'] = ::File.join(server_install_dir,
                                       server_install_subdir,
                                       '/startserver.sh')
    server['stop_tool'] = ::File.join(server_install_dir,
                                      server_install_subdir,
                                      '/stopserver.sh')
    server['authorization_tool'] = ::File.join(server_install_dir,
                                               server_install_subdir,
                                               '/tools/authorizeSoftware')
    default['arcgis']['python']['runtime_environment'] = ::File.join(server_install_dir,
                                                                     server_install_subdir,
                                                                     '/tools')
    server['local_directories_root'] = ::File.join(server_install_dir,
                                                   server_install_subdir,
                                                   'usr')

    server['authorization_file'] = ''
    server['keycodes'] = ::File.join(node['arcgis']['server']['install_dir'], 
                                     node['arcgis']['server']['install_subdir'], 
                                     'framework/runtime/.wine/drive_c/Program Files/ESRI/License' +
                                     node['arcgis']['server']['authorization_file_version'] + '/sysgen/keycodes')
    server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  node['arcgis']['version'],
                                  'ArcGISServer', 'Setup')
    server['lp-setup'] = node['arcgis']['server']['setup']

    case node['arcgis']['version']
    when '10.8'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Linux_108_172977.tar.gz')
    when '10.7.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Linux_1071_169796.tar.gz')
    when '10.7'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Linux_107_167707.tar.gz')
    when '10.6.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Linux_1061_164044.tar.gz')
      Chef::Log.warn 'Unsupported ArcGIS Server version' 
    when '10.6'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Linux_106_159989.tar.gz')
      Chef::Log.warn 'Unsupported ArcGIS Server version' 
    when '10.5.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Linux_1051_156429.tar.gz')
      Chef::Log.warn 'Unsupported ArcGIS Server version'
    when '10.5'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Linux_105_154052.tar.gz')
      Chef::Log.warn 'Unsupported ArcGIS Server version' 
    when '10.4.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_for_Server_Linux_1041_151978.tar.gz')
      Chef::Log.warn 'Unsupported ArcGIS Server version' 
    when '10.4'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_for_Server_Linux_104_149446.tar.gz')
      Chef::Log.warn 'Unsupported ArcGIS Server version' 
    else
      Chef::Log.warn 'Unsupported ArcGIS Server version'
    end
  end

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

  server['setup_options'] = ''
  server['authorization_options'] = ''
end
