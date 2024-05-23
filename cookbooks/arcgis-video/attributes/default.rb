#
# Cookbook Name:: arcgis-video
# Attributes:: default
#
# Copyright 2024 Esri
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

default['arcgis']['video_server'].tap do |video_server|

  video_server['wa_name'] = 'video'

  if node['fqdn'].nil? || node['arcgis']['configure_cloud_settings']
    video_server['url'] = "https://#{node['ipaddress']}:21443/arcgis"
    video_server['wa_url'] = "https://#{node['ipaddress']}/#{node['arcgis']['video_server']['wa_name']}"
    video_server['domain_name'] = node['ipaddress']
    video_server['hostname'] = node['ipaddress'] 
  else
    video_server['url'] = "https://#{node['fqdn']}:21443/arcgis"
    video_server['wa_url'] = "https://#{node['fqdn']}/#{node['arcgis']['video_server']['wa_name']}"
    video_server['domain_name'] = node['fqdn']
    video_server['hostname'] = '' # Use the default server machine hostname 
  end

  video_server['private_url'] = "https://#{node['arcgis']['video_server']['domain_name']}:21443/arcgis"
  video_server['web_context_url'] = "https://#{node['arcgis']['video_server']['domain_name']}/#{node['arcgis']['video_server']['wa_name']}"

  video_server['ports'] = '21080,21443'
  video_server['authorization_file'] = node['arcgis']['server']['authorization_file']
  video_server['authorization_file_version'] = node['arcgis']['server']['authorization_file_version']
  video_server['configure_autostart'] = true
  video_server['install_system_requirements'] = true

  video_server['setup_archive'] = ''

  video_server['admin_username'] = 'siteadmin'
  if ENV['ARCGIS_VIDEO_SERVER_ADMIN_PASSWORD'].nil?
    video_server['admin_password'] = nil
  else
    video_server['admin_password'] = ENV['ARCGIS_VIDEO_SERVER_ADMIN_PASSWORD']
  end

  video_server['config_store_type'] = 'FILESYSTEM'
  video_server['config_store_class_name'] = case node['arcgis']['video_server']['config_store_type']
                                            when 'AMAZON'
                                              'com.esri.arcgis.carbon.persistence.impl.amazon.AmazonConfigPersistence'
                                            when 'AZURE'
                                              'com.esri.arcgis.carbon.persistence.impl.azure.AzureConfigPersistence'
                                            else
                                              'com.esri.arcgis.carbon.persistence.impl.filesystem.FSConfigPersistence'
                                            end

  video_server['log_level'] = 'WARNING'
  video_server['max_log_file_age'] = 90

  video_server['system_properties'] = {}

  video_server['patches'] = []

  case node['platform']
  when 'windows'
    video_server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                        'ArcGIS ' + node['arcgis']['version'],
                                        'VideoServer', 'Setup.exe')
    video_server['install_dir'] = ::File.join(ENV['ProgramW6432'], 'ArcGIS\\Video').gsub('/', '\\')
    video_server['install_subdir'] = ''

    if node['arcgis']['video_server']['install_dir'].nil?
      video_server_install_dir = video_server['install_dir']
    else
      video_server_install_dir = node['arcgis']['video_server']['install_dir']
    end

    video_server['authorization_tool'] = ::File.join(video_server_install_dir,
      'tools\\SoftwareAuthorization\\SoftwareAuthorization.exe').gsub('/', '\\')
    video_server['keycodes'] = ::File.join(ENV['ProgramW6432'],
      "ESRI\\License#{node['arcgis']['video_server']['authorization_file_version']}\\sysgen\\keycodes").gsub('/', '\\')

    video_server['directories_root'] = 'C:\\arcgisvideoserver\\directories'
    video_server['config_store_connection_string'] = 'C:\\arcgisvideoserver\\config-store'
    video_server['log_dir'] = 'C:\\arcgisvideoserver\\logs'

    case node['arcgis']['version']
    when '11.3'
      video_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_Video_Server_Windows_113_190272.exe').gsub('/', '\\')
      video_server['product_code'] = '{401FBD2C-0D81-4D3B-8BCF-8D08C8F18EC9}'
    else
      Chef::Log.warn 'Unsupported ArcGIS Video Server version'
    end
  else # node['platform'] == 'linux'
    video_server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                        node['arcgis']['version'],
                                        'VideoServer', 'Setup')
    video_server['install_dir'] = "/home/#{node['arcgis']['run_as_user']}"
    video_server['install_subdir'] = node['arcgis']['video_server']['install_dir'].end_with?('/arcgis') ?
                                        'video' : 'arcgis/video'

    if node['arcgis']['video_server']['install_dir'].nil?
      video_server_install_dir = video_server['install_dir']
    else
      video_server_install_dir = node['arcgis']['video_server']['install_dir']
    end

    if node['arcgis']['video_server']['install_subdir'].nil?
      video_server_install_subdir = video_server['install_subdir']
    else
      video_server_install_subdir = node['arcgis']['video_server']['install_subdir']
    end

    video_server['authorization_tool'] = ::File.join(video_server_install_dir,
                                                     video_server_install_subdir,
                                                     '/tools/authorizeSoftware')

    video_server['directories_root'] = ::File.join(video_server_install_dir,
                                                   video_server_install_subdir,
                                                   'usr', 'directories')

    video_server['config_store_connection_string'] = ::File.join(video_server_install_dir,
                                                                 video_server_install_subdir,
                                                                 'usr', 'config-store')

    video_server['log_dir'] = ::File.join(video_server_install_dir,
                                          video_server_install_subdir,
                                          'usr', 'logs')

    case node['arcgis']['version']
    when '11.3'
      video_server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                  'ArcGIS_Video_Server_Linux_113_190341.tar.gz')
    else
      Chef::Log.warn 'Unsupported ArcGIS Video Server version'
    end
  end
end
