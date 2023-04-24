#
# Cookbook Name:: arcgis-notebooks
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

default['arcgis']['notebook_server'].tap do |notebook_server|

  notebook_server['wa_name'] = 'notebooks'

  if node['fqdn'].nil? || node['arcgis']['configure_cloud_settings']
    notebook_server['url'] = "https://#{node['ipaddress']}:11443/arcgis"
    notebook_server['wa_url'] = "https://#{node['ipaddress']}/#{node['arcgis']['notebook_server']['wa_name']}"
    notebook_server['domain_name'] = node['ipaddress']
    notebook_server['hostname'] = node['ipaddress'] 
  else
    notebook_server['url'] = "https://#{node['fqdn']}:11443/arcgis"
    notebook_server['wa_url'] = "https://#{node['fqdn']}/#{node['arcgis']['notebook_server']['wa_name']}"
    notebook_server['domain_name'] = node['fqdn']
    notebook_server['hostname'] = '' # Use the default server machine hostname 
  end

  notebook_server['private_url'] = "https://#{node['arcgis']['notebook_server']['domain_name']}:11443/arcgis"
  notebook_server['web_context_url'] = "https://#{node['arcgis']['notebook_server']['domain_name']}/#{node['arcgis']['notebook_server']['wa_name']}"

  notebook_server['ports'] = '11443'
  notebook_server['authorization_file'] = node['arcgis']['server']['authorization_file']
  notebook_server['authorization_file_version'] = node['arcgis']['server']['authorization_file_version']
  notebook_server['license_level'] = 'standard'
  notebook_server['configure_autostart'] = true
  notebook_server['install_system_requirements'] = true
  notebook_server['install_samples_data'] = false
  notebook_server['install_docker'] = true
  
  notebook_server['setup_archive'] = ''

  notebook_server['admin_username'] = 'siteadmin'
  if ENV['ARCGIS_NOTEBOOK_SERVER_ADMIN_PASSWORD'].nil?
    notebook_server['admin_password'] = nil
  else
    notebook_server['admin_password'] = ENV['ARCGIS_NOTEBOOK_SERVER_ADMIN_PASSWORD']
  end

  notebook_server['config_store_type'] = 'FILESYSTEM'
  notebook_server['config_store_class_name'] =  case node['arcgis']['notebook_server']['config_store_type']
                                                when 'AMAZON'
                                                  'com.esri.arcgis.carbon.persistence.impl.amazon.AmazonConfigPersistence'
                                                when 'AZURE'
                                                  'com.esri.arcgis.carbon.persistence.impl.azure.AzureConfigPersistence'
                                                else
                                                  'com.esri.arcgis.carbon.persistence.impl.filesystem.FSConfigPersistence'
                                                end


  notebook_server['log_level'] = 'WARNING'
  notebook_server['max_log_file_age'] = 90

  notebook_server['system_properties'] = {}

  case node['platform']
  when 'windows'
    notebook_server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                           'ArcGIS ' + node['arcgis']['version'],
                                           'NotebookServer', 'Setup.exe')
    notebook_server['data_setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                                'ArcGIS ' + node['arcgis']['version'],
                                                'NotebookServerData', 'Setup.exe')

    notebook_server['install_dir'] = ::File.join(ENV['ProgramW6432'], 'ArcGIS\\NotebookServer').gsub('/', '\\')
    notebook_server['install_subdir'] = ''
    notebook_server['authorization_tool'] = ::File.join(ENV['ProgramW6432'],
      'Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe').gsub('/', '\\')

    notebook_server['directories_root'] = 'C:\\arcgisnotebookserver\\directories'
    notebook_server['config_store_connection_string'] = 'C:\\arcgisnotebookserver\\config-store'
    notebook_server['workspace'] = 'C:\\arcgisnotebookserver\\arcgisworkspace'
    notebook_server['log_dir'] = 'C:\\arcgisnotebookserver\\logs'

    case node['arcgis']['version']
    when '10.9.1'
      notebook_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                     'ArcGIS_Notebook_Server_Windows_1091_180089.exe').gsub('/', '\\')
      notebook_server['standard_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Standard_1091_180090.tar.gz').gsub('/', '\\')
      notebook_server['advanced_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Advanced_1091_180091.tar.gz').gsub('/', '\\')
      notebook_server['product_code'] = '{39DA210D-DE33-4223-8268-F81D2674B501}'
      notebook_server['data_setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                          'ArcGIS_Notebook_Server_Samples_Data_Windows_1091_180107.exe').gsub('/', '\\')
      notebook_server['data_product_code'] = '{02AB631F-4427-4426-B515-8895F9315D22}'
    when '10.9'
      notebook_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                     'ArcGIS_Notebook_Server_Windows_109_177821.exe').gsub('/', '\\')
      notebook_server['standard_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Standard_109_177822.tar.gz').gsub('/', '\\')
      notebook_server['advanced_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Advanced_109_177823.tar.gz').gsub('/', '\\')
      notebook_server['product_code'] = '{9D0291C2-D01E-4411-A2D8-BB42740C9ECC}'
      notebook_server['data_setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                          'ArcGIS_Notebook_Server_Samples_Data_Windows_109_177842.exe').gsub('/', '\\')
      notebook_server['data_product_code'] = '{C2ECEE9C-961A-4EAF-9BD4-9FB0EBCFA535}'
    when '10.8.1'
      notebook_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                     'ArcGIS_Notebook_Server_1081_175250.exe').gsub('/', '\\')
      notebook_server['standard_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Standard_1081_175251.tar.gz').gsub('/', '\\')
      notebook_server['advanced_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Advanced_1081_175252.tar.gz').gsub('/', '\\')
      notebook_server['product_code'] = '{55DE1B3D-DDFB-4906-81F2-B573BAC25018}'
    when '10.8'
      notebook_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                     'ArcGIS_Notebook_Server_108_172941.exe').gsub('/', '\\')
      notebook_server['standard_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Standard_108_172942.tar.gz').gsub('/', '\\')
      notebook_server['advanced_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Advanced_108_172943.tar.gz').gsub('/', '\\')
      notebook_server['product_code'] = '{B1DB581E-E66C-4E58-B9E3-50A4D6CB5982}'
    else
      Chef::Log.warn 'Unsupported ArcGIS Notebook Server version'
    end
  else # node['platform'] == 'linux'
    notebook_server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                           node['arcgis']['version'],
                                           'NotebookServer_Linux', 'Setup')
    notebook_server['data_setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                                node['arcgis']['version'],
                                                'NotebookServerData_Linux', 'ArcGISNotebookServerSamplesData-Setup.sh')

    notebook_server['install_dir'] = "/home/#{node['arcgis']['run_as_user']}"
    notebook_server['install_subdir'] = node['arcgis']['notebook_server']['install_dir'].end_with?('/arcgis') ?
                                        'notebookserver' : 'arcgis/notebookserver'

    if node['arcgis']['notebook_server']['install_dir'].nil?
      notebook_server_install_dir = notebook_server['install_dir']
    else
      notebook_server_install_dir = node['arcgis']['notebook_server']['install_dir']
    end

    if node['arcgis']['notebook_server']['install_subdir'].nil?
      notebook_server_install_subdir = notebook_server['install_subdir']
    else
      notebook_server_install_subdir = node['arcgis']['notebook_server']['install_subdir']
    end

    notebook_server['authorization_tool'] = ::File.join(notebook_server_install_dir,
                                                        notebook_server_install_subdir,
                                                        '/tools/authorizeSoftware')

    notebook_server['keycodes'] = ::File.join(node['arcgis']['notebook_server']['install_dir'],
                                              node['arcgis']['notebook_server']['install_subdir'],
                                              'framework/.esri/License' +
                                              node['arcgis']['notebook_server']['authorization_file_version'] +
                                              '/sysgen/keycodes')

    notebook_server['directories_root'] = ::File.join(notebook_server_install_dir,
                                                      notebook_server_install_subdir,
                                                      'usr', 'directories')
    notebook_server['config_store_connection_string'] = ::File.join(notebook_server_install_dir,
                                                                    notebook_server_install_subdir,
                                                                    'usr', 'config-store')
    notebook_server['workspace'] = ::File.join(notebook_server_install_dir,
                                               notebook_server_install_subdir,
                                               'usr', 'arcgisworkspace')
    notebook_server['log_dir'] = ::File.join(notebook_server_install_dir,
                                             notebook_server_install_subdir,
                                             'usr', 'logs')

    notebook_server['patches'] = []

    case node['arcgis']['version']
    when '11.1'
      notebook_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                     'ArcGIS_Notebook_Server_Linux_111_185323.tar.gz')
      notebook_server['standard_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Standard_111_185262.tar.gz')
      notebook_server['advanced_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Advanced_111_185263.tar.gz')
      notebook_server['data_setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                          'ArcGIS_Notebook_Server_Samples_Data_Linux_111_185328.tar.gz')
    when '11.0'
      notebook_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                     'ArcGIS_Notebook_Server_Linux_110_183044.tar.gz')
      notebook_server['standard_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Standard_110_182933.tar.gz')
      notebook_server['advanced_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Advanced_110_182934.tar.gz')
      notebook_server['data_setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                          'ArcGIS_Notebook_Server_Samples_Data_Linux_110_183049.tar.gz')
    when '10.9.1'
      notebook_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                     'ArcGIS_Notebook_Server_Linux_1091_180226.tar.gz')
      notebook_server['standard_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Standard_1091_180090.tar.gz')
      notebook_server['advanced_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Advanced_1091_180091.tar.gz')
      notebook_server['data_setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                          'ArcGIS_Notebook_Server_Samples_Data_Linux_1091_180232.tar.gz')
    when '10.9'
      notebook_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                     'ArcGIS_Notebook_Server_Linux_109_177908.tar.gz')
      notebook_server['standard_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Standard_109_177822.tar.gz')
      notebook_server['advanced_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Advanced_109_177823.tar.gz')
      notebook_server['data_setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                          'ArcGIS_Notebook_Server_Samples_Data_Linux_109_177914.tar.gz')
     when '10.8.1'
      notebook_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                     'ArcGIS_Notebook_Server_Linux_1081_175333.tar.gz')
      notebook_server['standard_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Standard_1081_175251.tar.gz')
      notebook_server['advanced_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Advanced_1081_175252.tar.gz')
    when '10.8'
      notebook_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                     'ArcGIS_Notebook_Server_Linux_108_173012.tar.gz')
      notebook_server['standard_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Standard_108_172942.tar.gz')
      notebook_server['advanced_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Advanced_108_172943.tar.gz')
    when '10.7.1'
      notebook_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                     'ArcGIS_Notebook_Server_Linux_1071_169927.tar.gz')
      notebook_server['standard_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Standard_1071_169736.tar.gz')
      notebook_server['advanced_images'] = ::File.join(node['arcgis']['repository']['archives'],
                                                       'ArcGIS_Notebook_Docker_Advanced_1071_169738.tar.gz')
    else
      Chef::Log.warn 'Unsupported ArcGIS Notebook Server version'
    end
  end
end
