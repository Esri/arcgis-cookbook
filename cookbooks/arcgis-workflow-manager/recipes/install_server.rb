#
# Cookbook Name:: arcgis-workflow-manager
# Recipe:: install_server
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
#

arcgis_workflow_manager_server "Install ArcGIS Workflow Manager Server system requirements" do
  ports node['arcgis']['workflow_manager_server']['ports']
  only_if { node['arcgis']['server']['install_system_requirements'] }
  action :system
end

arcgis_workflow_manager_server 'Unpack ArcGIS Workflow Manager Server Setup' do
  setup_archive node['arcgis']['workflow_manager_server']['setup_archive']
  setups_repo node['arcgis']['repository']['setups']
  run_as_user node['arcgis']['run_as_user']
  only_if { ::File.exist?(node['arcgis']['workflow_manager_server']['setup_archive']) &&
            !::File.exist?(node['arcgis']['workflow_manager_server']['setup']) }
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['workflow_manager_server']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                                node['hostname'],
                                                node['arcgis']['version'],
                                                :ArcWorkflowManager) }
  end
  action :unpack
end

arcgis_workflow_manager_server 'Setup ArcGIS Workflow Manager Server' do
  setup node['arcgis']['workflow_manager_server']['setup']
  install_dir node['arcgis']['server']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  run_as_msa node['arcgis']['run_as_msa']
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['workflow_manager_server']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                                node['hostname'],
                                                node['arcgis']['version'],
                                                :ArcWorkflowManager) }
  end
  action :install
end

arcgis_workflow_manager_server 'Configure workflowmanager service' do
  install_dir node['arcgis']['server']['install_dir']
  action :configure_autostart
end

arcgis_workflow_manager_server 'Start ArcGIS Workflow Manager Server' do
  action :start
end
