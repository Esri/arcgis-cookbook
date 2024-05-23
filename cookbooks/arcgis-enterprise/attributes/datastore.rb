#
# Cookbook Name:: arcgis-enterprise
# Attributes:: datastore
#
# Copyright 2023-2024 Esri
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

default['arcgis']['data_store'].tap do |data_store|

  if node['arcgis']['configure_cloud_settings']
    data_store['preferredidentifier'] = 'ip'
  else
    data_store['preferredidentifier'] = 'hostname'
  end

  data_store['hostidentifier'] = ''

  data_store['types'] = 'tileCache,relational'
  data_store['mode'] = ''
  data_store['roles'] = ''
  data_store['configure_autostart'] = true
  data_store['install_system_requirements'] = true
  data_store['force_remove_machine'] = false
  data_store['setup_archive'] = ''
  data_store['product_code'] = ''
  data_store['ports'] = '2443,4369,9220,9320,9820,9829,9830,9831,9840,9876,9900,25672,44369,45671,45672,29079-29090'

  data_store['patches'] = []
  
  case node['platform']
  when 'windows'
    data_store['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                      "ArcGIS #{node['arcgis']['version']}",
                                      'ArcGISDataStore', 'Setup.exe').gsub('/', '\\')
    data_store['lp-setup'] = node['arcgis']['data_store']['setup']
    data_store['install_dir'] = ::File.join(ENV['ProgramW6432'], 'ArcGIS\\DataStore').gsub('/', '\\')
    data_store['install_subdir'] = ''
    data_store['data_dir'] = 'C:\\arcgisdatastore'
    data_store['local_backup_dir'] = 'C:\\arcgisbackup'
    data_store['patch_registry'] ='SOFTWARE\\ESRI\\ArcGIS Data Store\\Updates'

    case node['arcgis']['version']
    when '11.3'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                'ArcGIS_DataStore_Windows_113_190233.exe').gsub('/', '\\')
      data_store['product_code'] = '{E4FC0BED-0F94-49D4-9AF5-BBA64AED3787}'
    when '11.2'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                'ArcGIS_DataStore_Windows_112_188252.exe').gsub('/', '\\')
      data_store['product_code'] = '{FE7F4A14-4D96-4B31-8937-BA19C0A92DDB}'
    when '11.1'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                'ArcGIS_DataStore_Windows_111_185221.exe').gsub('/', '\\')
      data_store['product_code'] = '{391B3A39-0951-43E3-991D-82C82CA6E4A4}'
    when '11.0'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                'ArcGIS_DataStore_Windows_110_182887.exe').gsub('/', '\\')
      data_store['product_code'] = '{ABCEFF81-861D-482A-A20E-8542814C03BD}'
    when '10.9.1'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                'ArcGIS_DataStore_Windows_1091_180054.exe').gsub('/', '\\')
      data_store['product_code'] = '{30BB3697-7815-406B-8F0C-EAAFB723AA97}'
    else
      Chef::Log.warn 'Unsupported ArcGIS Data Store version'
    end
  else # node['platform'] == 'linux'
    data_store['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                      node['arcgis']['version'],
                                      'ArcGISDataStore_Linux', 'Setup')
    data_store['lp-setup'] = node['arcgis']['data_store']['setup']

    case node['arcgis']['version']
    when '11.3'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                'ArcGIS_DataStore_Linux_113_190318.tar.gz')
    when '11.2'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                'ArcGIS_DataStore_Linux_112_188340.tar.gz')
    when '11.1'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                'ArcGIS_DataStore_Linux_111_185305.tar.gz')
    when '11.0'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                'ArcGIS_DataStore_Linux_110_182986.tar.gz')
    when '10.9.1'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                'ArcGIS_DataStore_Linux_1091_180204.tar.gz')
    else
      Chef::Log.warn 'Unsupported ArcGIS Data Store version'
    end

    data_store['install_dir'] = '/'
    data_store['install_subdir'] = 'arcgis/datastore'

    if node['arcgis']['data_store']['install_dir'].nil?
      data_store_install_dir = data_store['install_dir']
    else
      data_store_install_dir = node['arcgis']['data_store']['install_dir']
    end

    if node['arcgis']['data_store']['install_subdir'].nil?
      data_store_install_subdir = data_store['install_subdir']
    else
      data_store_install_subdir = node['arcgis']['data_store']['install_subdir']
    end

    data_store['start_tool'] = ::File.join(data_store_install_dir,
                                           data_store_install_subdir,
                                           'startdatastore.sh')
    data_store['stop_tool'] = ::File.join(data_store_install_dir,
                                          data_store_install_subdir,
                                          'stopdatastore.sh')
    data_store['data_dir'] = ::File.join(data_store_install_dir,
                                         data_store_install_subdir,
                                         'usr/arcgisdatastore')
    data_store['local_backup_dir'] = ::File.join(data_store_install_dir,
                                                 data_store_install_subdir,
                                                 'usr/arcgisbackup')
    data_store['patch_log'] = ::File.join(data_store_install_dir,
                                          data_store_install_subdir,
                                          '.ESRI_DS_PATCH_LOG')

    data_store['sysctl_conf'] = '/etc/sysctl.conf'
    data_store['vm_max_map_count'] = 262144
    data_store['vm_swappiness'] = 1
  end

  if node['arcgis']['data_store']['local_backup_dir'].nil?
    data_store['backup_dir'] = data_store['local_backup_dir']
  else
    data_store['backup_dir'] = node['arcgis']['data_store']['local_backup_dir']
  end

  data_store['relational']['backup_type'] = 'fs'
  data_store['tilecache']['backup_type'] = 'fs'
  data_store['object']['backup_type'] = 'none'

  if node['arcgis']['data_store']['backup_dir'].nil?
    data_store['relational']['backup_location'] = ::File.join(data_store['backup_dir'], 'relational')
    data_store['tilecache']['backup_location'] = ::File.join(data_store['backup_dir'], 'tilecache')
    data_store['object']['backup_location'] = ::File.join(data_store['backup_dir'], 'object')
  else
    data_store['relational']['backup_location'] = ::File.join(node['arcgis']['data_store']['backup_dir'], 'relational')
    data_store['tilecache']['backup_location'] = ::File.join(node['arcgis']['data_store']['backup_dir'], 'tilecache')
    data_store['object']['backup_location'] = ::File.join(node['arcgis']['data_store']['backup_dir'], 'object')
  end

  data_store['setup_options'] = ''
end
