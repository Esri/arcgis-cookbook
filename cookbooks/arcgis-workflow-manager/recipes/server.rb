#
# Cookbook Name:: arcgis-workflow-manager
# Recipe:: server
#
# Copyright 2021-2024 Esri
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
#

include_recipe 'arcgis-workflow-manager::install_server'

arcgis_workflow_manager_server 'Authorize ArcGIS Workflow Manager Server' do
  authorization_file node['arcgis']['workflow_manager_server']['authorization_file']
  authorization_file_version node['arcgis']['workflow_manager_server']['authorization_file_version']
  authorization_options node['arcgis']['workflow_manager_server']['authorization_options']
  retries 5
  retry_delay 60
  not_if { node['arcgis']['workflow_manager_server']['authorization_file'] == '' ||
           ::File.exists?(node['arcgis']['workflow_manager_server']['cached_authorization_file']) &&
           FileUtils.compare_file(node['arcgis']['workflow_manager_server']['authorization_file'],
                                  node['arcgis']['workflow_manager_server']['cached_authorization_file']) }
  action :authorize
end
