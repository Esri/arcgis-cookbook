#
# Cookbook Name:: arcgis-workflow-manager
# Recipe:: install_patches
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
#

# Install ArcGIS Workflow Manager Server patches

arcgis_workflow_manager_server 'Stop ArcGIS Workflow Manager Server before patching' do
  not_if { node['arcgis']['workflow_manager_server']['patches'].empty? }
  action :stop
end

node['arcgis']['workflow_manager_server']['patches'].each do |patch|
  arcgis_enterprise_patches "Install patch #{patch}" do
    patch_folder node['arcgis']['repository']['patches']
    patch patch
    run_as_user node['arcgis']['run_as_user']
    if node['platform'] == 'windows'
      patch_registry node['arcgis']['workflow_manager_server']['patch_registry']
    else
      patch_log node['arcgis']['workflow_manager_server']['patch_log']      
    end    
    action :install
  end
end

arcgis_workflow_manager_server 'Start ArcGIS Workflow Manager Server after patching' do
  not_if { node['arcgis']['workflow_manager_server']['patches'].empty? }
  action :start
end
