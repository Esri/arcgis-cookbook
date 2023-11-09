#
# Cookbook Name:: arcgis-enterprise
# Attributes:: server
#
# Copyright 2023 Esri
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
    server['hostname'] = node['ipaddress']
    server['url'] = "https://#{node['ipaddress']}:6443/arcgis"
    server['wa_url'] = "https://#{node['ipaddress']}/#{server_wa_name}"
  else
    server_domain_name = node['fqdn']
    server['domain_name'] = server_domain_name
    server['hostname'] = '' # Use the default server machine hostname 
    server['url'] = "https://#{node['fqdn']}:6443/arcgis"
    server['wa_url'] = "https://#{node['fqdn']}/#{server_wa_name}"
  end

  unless node['arcgis']['server']['domain_name'].nil?
    server_domain_name = node['arcgis']['server']['domain_name']
  end

  server['private_url'] = "https://#{server_domain_name}:6443/arcgis"
  server['web_context_url'] = "https://#{server_domain_name}/#{server_wa_name}"
  server['admin_username'] = 'admin'
  if ENV['ARCGIS_SERVER_ADMIN_PASSWORD'].nil?
    server['admin_password'] = nil
  else
    server['admin_password'] = ENV['ARCGIS_SERVER_ADMIN_PASSWORD']
  end
  server['managed_database'] = '' # deprecated
  server['replicated_database'] = '' # deprecated
  server['data_items'] = []
  server['keystore_file'] = ''
  if ENV['ARCGIS_SERVER_KEYSTORE_PASSWORD'].nil?
    server['keystore_password'] = nil
  else
    server['keystore_password'] = ENV['ARCGIS_SERVER_KEYSTORE_PASSWORD']
  end
  server['cert_alias'] = server_domain_name
  server['root_cert'] = ''
  server['root_cert_alias'] = ''
  server['system_properties'] = {}
  server['log_level'] = 'WARNING'
  server['max_log_file_age'] = 90
  server['is_hosting'] = true
  server['configure_autostart'] = true
  server['install_system_requirements'] = true
  server['use_join_site_tool'] = false
  server['pull_license'] = false
  server['soc_max_heap_size'] = 64
  server['protocol'] = 'HTTPS'
  server['authentication_mode'] = ''
  server['authentication_tier'] = ''
  server['hsts_enabled'] = false
  server['virtual_dirs_security_enabled'] = false
  server['allow_direct_access'] = true
  server['allowed_admin_access_ips'] = ''
  server['https_protocols'] = ''
  server['cipher_suites'] = ''

  server['ports'] = '1098,6006,6080,6099,6443'
  server['geoanalytics_ports'] = '7077,12181,12182,12190,56540-56545'

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

  # disable nodeagent plugins on aws ec2
  server['disable_nodeagent_plugins'] = true

  server['services_dir_enabled'] = true

  server['patches'] = []

  case node['platform']
  when 'windows'
    server['authorization_file'] = ''
    server['keycodes'] = ::File.join(ENV['ProgramW6432'],
                                     "ESRI\\License#{node['arcgis']['server']['authorization_file_version']}\\sysgen\\keycodes").gsub('/', '\\')
    server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  "ArcGIS #{node['arcgis']['version']}",
                                  'ArcGISServer', 'Setup.exe').gsub('/', '\\')
    server['lp-setup'] = node['arcgis']['server']['setup']
    server['install_dir'] = ::File.join(ENV['ProgramW6432'], 'ArcGIS\\Server').gsub('/', '\\')
    server['install_subdir'] = ''

    if node['arcgis']['server']['install_dir'].nil?
      server_install_dir = server['install_dir']
    else
      server_install_dir = node['arcgis']['server']['install_dir']
    end

    server['local_directories_root'] = 'C:\\arcgisserver'
    server['authorization_tool'] = ::File.join(server_install_dir,
                                               'tools\\SoftwareAuthorization',
                                               'SoftwareAuthorization.exe').gsub('/', '\\')

    server['configuration_utility'] = ::File.join(server_install_dir, 
                                                  'framework\\runtime\\ArcGIS\\bin',
                                                  'ServerConfigurationUtility.exe').gsub('/', '\\')    

    case node['arcgis']['version']
    when '11.2'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Windows_112_188239.exe').gsub('/', '\\')
      server['product_code'] = '{4130E39E-FD8C-4DE0-AE91-AFEC71063B2D}'
      default['arcgis']['python']['runtime_environment'] = File.join(
        server_install_dir, 
        'framework\\runtime\\ArcGIS\\bin\\Python\\envs\\arcgispro-py3').gsub('/', '\\')
      server['patch_registry'] ='SOFTWARE\\ESRI\\Server11.2\\Updates'        
    when '11.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Windows_111_185208.exe').gsub('/', '\\')
      server['product_code'] = '{0F6C2D4F-9D41-4D25-A8AF-51E328D7CD8F}'
      default['arcgis']['python']['runtime_environment'] = File.join(
        server_install_dir, 
        'framework\\runtime\\ArcGIS\\bin\\Python\\envs\\arcgispro-py3').gsub('/', '\\')
      server['patch_registry'] = 'SOFTWARE\\ESRI\\Server11.1\\Updates'
      server['authorization_tool'] = ::File.join(ENV['ProgramW6432'],
                                                 'Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe').gsub('/', '\\')    
      server['configuration_utility'] = ::File.join(server_install_dir, 
                                                    'bin', 'ServerConfigurationUtility.exe').gsub('/', '\\')    
    when '11.0'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Windows_110_182874.exe').gsub('/', '\\')
      server['product_code'] = '{A14CF942-415B-461C-BE3C-5B37E34BC6AE}'
      default['arcgis']['python']['runtime_environment'] = File.join(server_install_dir, 
                                                                     'framework\\runtime\\ArcGIS\\bin\\Python\\envs\\arcgispro-py3').gsub('/', '\\')
      server['patch_registry'] = 'SOFTWARE\\ESRI\\Server11.0\\Updates'
      server['authorization_tool'] = ::File.join(ENV['ProgramW6432'],
                                                 'Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe').gsub('/', '\\')
      server['configuration_utility'] = ::File.join(server_install_dir,
                                                    'bin', 'ServerConfigurationUtility.exe').gsub('/', '\\')
    when '10.9.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Windows_1091_180041.exe').gsub('/', '\\')
      server['product_code'] = '{E4A5FD24-5C61-4846-B084-C7AD4BB1CF19}'
      default['arcgis']['python']['runtime_environment'] = File.join(node['arcgis']['python']['install_dir'], 
                                                                     "ArcGISx6410.9").gsub('/', '\\')
      server['patch_registry'] = 'SOFTWARE\\ESRI\\Server10.9\\Updates'
      server['authorization_tool'] = ::File.join(ENV['ProgramW6432'],
                                                 'Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe').gsub('/', '\\')      
      server['configuration_utility'] = ::File.join(server_install_dir,
                                                    'bin', 'ServerConfigurationUtility.exe').gsub('/', '\\')
    when '10.9'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Windows_109_177775.exe').gsub('/', '\\')
      server['product_code'] = '{32A62D8E-BE72-4B28-AA0E-FE546D827240}'
      default['arcgis']['python']['runtime_environment'] = File.join(node['arcgis']['python']['install_dir'], 
                                                                     "ArcGISx6410.9").gsub('/', '\\')
      server['patch_registry'] = 'SOFTWARE\\ESRI\\Server10.9\\Updates'
      server['authorization_tool'] = ::File.join(ENV['ProgramW6432'],
                                                 'Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe').gsub('/', '\\')      
      server['configuration_utility'] = ::File.join(server_install_dir,
                                                    'bin', 'ServerConfigurationUtility.exe').gsub('/', '\\')
    when '10.8.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Windows_1081_175203.exe').gsub('/', '\\')
      server['product_code'] = '{E9B85E31-4C31-4528-996B-F06E213F8BB3}'
      default['arcgis']['python']['runtime_environment'] = File.join(node['arcgis']['python']['install_dir'], 
                                                                     "ArcGISx6410.8").gsub('/', '\\')
      server['patch_registry'] = 'SOFTWARE\\ESRI\\Server10.8\\Updates'
      server['geoanalytics_ports'] = '2181,2182,2190,7077,56540-56545'
      server['authorization_tool'] = ::File.join(ENV['ProgramW6432'],
                                                 'Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe').gsub('/', '\\')      
      server['configuration_utility'] = ::File.join(server_install_dir,
                                                    'bin', 'ServerConfigurationUtility.exe').gsub('/', '\\')
    when '10.8'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Windows_108_172859.exe').gsub('/', '\\')
      server['product_code'] = '{458BF5FF-2DF8-426B-AEBC-BE4C47DB6B54}'
      default['arcgis']['python']['runtime_environment'] = File.join(node['arcgis']['python']['install_dir'], 
                                                                     "ArcGISx6410.8").gsub('/', '\\')
      server['patch_registry'] = 'SOFTWARE\\ESRI\\Server10.8\\Updates'
      server['geoanalytics_ports'] = '2181,2182,2190,7077,56540-56545'
      server['authorization_tool'] = ::File.join(ENV['ProgramW6432'],
                                                 'Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe').gsub('/', '\\')      
      server['configuration_utility'] = ::File.join(server_install_dir,
                                                    'bin', 'ServerConfigurationUtility.exe').gsub('/', '\\')
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
    server['patch_log'] = ::File.join(server_install_dir,
                                      server_install_subdir,
                                      '.ESRI_S_PATCH_LOG')

    server['authorization_file'] = ''
    server['keycodes'] = ::File.join(server_install_dir, 
                                     server_install_subdir, 
                                     'framework/runtime/.wine/drive_c/Program Files/ESRI/License' +
                                     node['arcgis']['server']['authorization_file_version'] + '/sysgen/keycodes')
    server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  node['arcgis']['version'],
                                  'ArcGISServer', 'Setup')
    server['lp-setup'] = node['arcgis']['server']['setup']

    case node['arcgis']['version']
    when '11.2'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Linux_112_188327.tar.gz')
    when '11.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Linux_111_185292.tar.gz')
    when '11.0'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Linux_110_182973.tar.gz')
    when '10.9.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Linux_1091_180182.tar.gz')
    when '10.9'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Linux_109_177864.tar.gz')
    when '10.8.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Linux_1081_175289.tar.gz')
    when '10.8'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Server_Linux_108_172977.tar.gz')
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
