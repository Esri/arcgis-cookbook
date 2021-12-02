#
# Cookbook Name:: arcgis-workflow-manager
# Attributes:: webapp
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

default['arcgis']['workflow_manager_webapp'].tap do |webapp|
  case node['platform']
  when 'windows'
    webapp['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  'ArcGIS ' + node['arcgis']['version'],
                                  'WorkflowManagerWebApp', 'Setup.exe')

    case node['arcgis']['version']
    when '10.9'
      webapp['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_WebApp_109_177833.exe').gsub('/', '\\')
      webapp['product_code'] = '{28F45C9F-9581-4F82-9377-5B165D0D8580}'
    when '10.8.1'
      webapp['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_WebApp_1081_175262.exe').gsub('/', '\\')
      webapp['product_code'] = '{96A58AC8-C040-4E4A-A118-BE963BF1A8CF}'
    end
  else # node['platform'] == 'linux'
    webapp['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  node['arcgis']['version'],
                                  'WorkflowManagerWebApp', 'Setup.sh')
    case node['arcgis']['version']
    when '10.9'
      webapp['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_WebApp_109_178649.tar.gz')
    when '10.8.1'
      webapp['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'ArcGIS_Workflow_Manager_WebApp_1081_175336.tar.gz')
    end
  end
end
