#
# Cookbook Name:: arcgis-enterprise
# Attributes:: datastore
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

default['arcgis']['data_store'].tap do |data_store|

  case ENV['arcgis_cloud_platform']
  when 'aws'
    data_store['preferredidentifier'] = 'ip'
  else
    data_store['preferredidentifier'] = 'hostname'
  end

  data_store['types'] = 'tileCache,relational'
  data_store['configure_autostart'] = true
  data_store['install_system_requirements'] = true

  case node['platform']
  when 'windows'
    data_store['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                      'ArcGIS ' + node['arcgis']['version'],
                                      'ArcGISDataStore', 'Setup.exe')
    data_store['lp-setup'] = node['arcgis']['data_store']['setup']
    data_store['install_dir'] = ENV['ProgramW6432'] + '\\ArcGIS\\DataStore'
    data_store['data_dir'] = 'C:\\arcgisdatastore'

    if node['arcgis']['data_store']['data_dir'].nil?
      data_store['local_backup_dir'] = data_store['data_dir'] + '\\backup'
    else
      data_store['local_backup_dir'] = node['arcgis']['data_store']['data_dir'] + '\\backup'
    end

    if node['arcgis']['data_store']['local_backup_dir'].nil?
      data_store['backup_dir'] = data_store['local_backup_dir']
    else
      data_store['backup_dir'] = node['arcgis']['data_store']['local_backup_dir']
    end

    case node['arcgis']['version']
    when '10.6'
        data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_DataStore_Windows_106_161832.exe')
        data_store['product_code'] = '{846636C1-53BB-459D-B66D-524F79E40396}'
    when '10.5.1'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_DataStore_Windows_1051_156366.exe')
      data_store['product_code'] = '{75276C83-E88C-43F6-B481-100DA4D64F71}'
    when '10.5'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_DataStore_Windows_105_154006.exe')
      data_store['product_code'] = '{5EA81114-6FA7-4B4C-BD72-D1C882088AAC}'
    when '10.4.1'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_DataStore_Windows_1041_151782.exe')
      data_store['product_code'] = '{A944E0A7-D268-41CA-B96E-8434457B051B}'
    when '10.4'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_DataStore_Windows_104_149437.exe')
      data_store['product_code'] = '{C351BC6D-BF25-487D-99AB-C963D590A8E8}'
    else
      throw 'Unsupported ArcGIS version'
    end
  else # node['platform'] == 'linux'
    data_store['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                      node['arcgis']['version'],
                                      'ArcGISDataStore_Linux', 'Setup')
    data_store['lp-setup'] = node['arcgis']['data_store']['setup']

    case node['arcgis']['version']
    when '10.6'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_DataStore_Linux_106_161810.tar.gz')
    when '10.5.1'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_DataStore_Linux_1051_156441.tar.gz')
    when '10.5'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_DataStore_Linux_105_154054.tar.gz')
    when '10.4.1'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_DataStore_Linux_1041_152011.tar.gz')
    when '10.4'
      data_store['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_DataStore_Linux_104_149449.tar.gz')
    else
      throw 'Unsupported ArcGIS version'
    end

    data_store['install_dir'] = '/'
    data_store['install_subdir'] = 'arcgis/datastore'
    data_store['start_tool'] = ::File.join(node['arcgis']['data_store']['install_dir'],
                                           node['arcgis']['data_store']['install_subdir'],
                                           '/startdatastore.sh')
    data_store['stop_tool'] = ::File.join(node['arcgis']['data_store']['install_dir'],
                                          node['arcgis']['data_store']['install_subdir'],
                                          '/stopdatastore.sh')
    data_store['data_dir'] = ::File.join(node['arcgis']['data_store']['install_dir'],
                                         node['arcgis']['data_store']['install_subdir'],
                                         '/usr/arcgisdatastore')
    data_store['local_backup_dir'] = node['arcgis']['data_store']['data_dir'] + '/backup'
    data_store['backup_dir'] = node['arcgis']['data_store']['local_backup_dir']
    data_store['sysctl_conf'] = '/etc/sysctl.conf'
    data_store['vm_max_map_count'] = 262144
    data_store['vm_swappiness'] = 1
  end

end
