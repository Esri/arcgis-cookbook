#
# Cookbook Name:: arcgis-workflow-manager
# Attributes:: server
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

default['arcgis']['workflow_manager_server'].tap do |server|
  server['authorization_file'] = node['arcgis']['server']['authorization_file']
  server['authorization_file_version'] = node['arcgis']['server']['authorization_file_version']
  unless node['arcgis']['workflow_manager_server']['authorization_file'].nil?
    server['cached_authorization_file'] = ::File.join(Chef::Config[:file_cache_path],
                                                      ::File.basename(node['arcgis']['workflow_manager_server']['authorization_file']))
  end

  server['ports'] = '9820,9830,9840,9880,13443,13820,13830,13840'

  server['patches'] = []

  server['distributed_data_provider'] = false
  server['enabled_modules'] = node['arcgis']['workflow_manager_server']['distributed_data_provider'] ? 
                              'esri.workflow.utils.inject.DistributedDataProvider' :  nil
  server['disabled_modules'] = node['arcgis']['workflow_manager_server']['distributed_data_provider'] ? 
                               'esri.workflow.utils.inject.LocalDataProvider' : nil

  case node['platform']
  when 'windows'
    server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  'ArcGIS ' + node['arcgis']['version'],
                                  'ArcGISWorkflowManagerServer', 'Setup.exe')

    case node['arcgis']['version']
    when '11.3'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_Server_113_190273.exe').gsub('/', '\\')
      server['product_code'] = '{A5AC0A8B-A7A2-45DD-8EDC-7A4F762A4192}'
      server['patch_registry'] ='SOFTWARE\\ESRI\\workflowmanager\\Server\\11.3\\Updates'
    when '11.2'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_Server_112_188216.exe').gsub('/', '\\')
      server['product_code'] = '{434D85E9-9CFB-4683-9FFF-5C38CDEBD676}'
      server['patch_registry'] ='SOFTWARE\\ESRI\\workflowmanager\\Server\\11.2\\Updates'
    when '11.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_Server_111_185267.exe').gsub('/', '\\')
      server['product_code'] = '{BCCADE20-4363-4D62-AE55-BB51329210CF}'
      server['patch_registry'] ='SOFTWARE\\ESRI\\workflowmanager\\Server\\11.1\\Updates'
    when '11.0'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_Server_110_182937.exe').gsub('/', '\\')
      server['product_code'] = '{1B27C0F2-81E9-4F1F-9506-46F937605674}'
      server['patch_registry'] ='SOFTWARE\\ESRI\\workflowmanager\\Server\\11.0\\Updates'
    when '10.9.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_Server_1091_180100.exe').gsub('/', '\\')
      server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                    'ArcGIS ' + node['arcgis']['version'],
                                    'WorkflowManagerServer', 'Setup.exe')
      server['product_code'] = '{9EF4FCC5-64EE-4719-B050-41E5AB85857B}'
      server['patch_registry'] ='SOFTWARE\\ESRI\\workflowmanager\\Server\\10.9\\Updates'
    else
      Chef::Log.warn 'Unsupported ArcGIS Workflow Manager Server version'
    end
  else # node['platform'] == 'linux'
    server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  node['arcgis']['version'],
                                  'ArcGISWorkflowManagerServer', 'Setup.sh')

    case node['arcgis']['version']
    when '11.3'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_Server_113_190342.tar.gz')
    when '11.2'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_Server_112_188363.tar.gz')
    when '11.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_Server_111_185325.tar.gz')
    when '11.0'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_Server_110_183046.tar.gz')
    when '10.9.1'
      server['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_Server_1091_180228.tar.gz')
      server['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                    node['arcgis']['version'],
                                    'WorkflowManagerServer', 'Setup.sh')
    else
      Chef::Log.warn 'Unsupported ArcGIS Workflow Manager Server version'
    end

    if node['arcgis']['server']['install_dir'].nil?
      server_install_dir = default['arcgis']['server']['install_dir']
    else
      server_install_dir = node['arcgis']['server']['install_dir']
    end

    if node['arcgis']['server']['install_subdir'].nil?
      server_install_subdir = default['arcgis']['server']['install_subdir']
    else
      server_install_subdir = node['arcgis']['server']['install_subdir']
    end

    server['patch_log'] = ::File.join(server_install_dir,
                                      server_install_subdir,
                                      'WorkflowManager',
                                      '.ESRI_WMXS_PATCH_LOG')
  end
end
