#
# Cookbook Name:: arcgis-workflow-manager
# Attributes:: server
#
# Copyright 2021 Esri
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

default['arcgis']['workflow_manager_server'].tap do |server|
  server['authorization_file'] = node['arcgis']['server']['authorization_file']
  server['authorization_file_version'] = node['arcgis']['server']['authorization_file_version']
  unless node['arcgis']['workflow_manager_server']['authorization_file'].nil?
    server['cached_authorization_file'] = ::File.join(Chef::Config[:file_cache_path],
                                                      ::File.basename(node['arcgis']['workflow_manager_server']['authorization_file']))
  end

  server['ports'] = '9830,9820,9840,9880,13443'

  case node['platform']
  when 'windows'
    server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  'ArcGIS ' + node['arcgis']['version'],
                                  'WorkflowManagerServer', 'Setup.exe')

    case node['arcgis']['version']
    when '10.9.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_Server_1091_180100.exe').gsub('/', '\\')
      server['product_code'] = '{9EF4FCC5-64EE-4719-B050-41E5AB85857B}'
    when '10.9'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_Server_109_177832.exe').gsub('/', '\\')
      server['product_code'] = '{80C5D637-B20F-4D11-882C-33C17918EF0E}'
    when '10.8.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_Server_1081_175261.exe').gsub('/', '\\')
      server['product_code'] = '{C0F0FCAB-2B65-4B8E-8614-531690B7CF9C}'
    else
      Chef::Log.warn 'Unsupported ArcGIS Workflow Manager Server version'
    end
  else # node['platform'] == 'linux'
    server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  node['arcgis']['version'],
                                  'WorkflowManagerServer', 'Setup.sh')
    case node['arcgis']['version']
    when '10.9.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_Server_1091_180228.tar.gz')
    when '10.9'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_Server_109_177910.tar.gz')
    when '10.8.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_Server_1081_175335.tar.gz')
    else
      Chef::Log.warn 'Unsupported ArcGIS Workflow Manager Server version'
    end
  end
end
