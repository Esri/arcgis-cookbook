#
# Cookbook Name:: arcgis-notebooks
# Recipe:: samples_data
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

arcgis_notebooks_data 'Unpack ArcGIS Notebook Server Samples Data Setup' do
  setup_archive node['arcgis']['notebook_server']['data_setup_archive']
  setups_repo node['arcgis']['repository']['setups']
  run_as_user node['arcgis']['run_as_user']
  only_if { !node['arcgis']['notebook_server']['data_setup_archive'].nil? &&
            ::File.exist?(node['arcgis']['notebook_server']['data_setup_archive']) &&
            !::File.exist?(node['arcgis']['notebook_server']['data_setup']) }
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['notebook_server']['data_product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                               node['hostname'],
                                               node['arcgis']['version'],
                                               :ArcGISNotebookServer_ArcGISNotebookServerSamplesData) }
  end
  action :unpack
end

arcgis_notebooks_data 'Setup ArcGIS Notebook Server Samples Data' do
  setup node['arcgis']['notebook_server']['data_setup']
  install_dir node['arcgis']['notebook_server']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['notebook_server']['data_product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                               node['hostname'],
                                               node['arcgis']['version'],
                                               :ArcGISNotebookServer_ArcGISNotebookServerSamplesData) }
  end
  action :install
end

arcgis_notebooks_data 'Run postinstallation utility for ArcGIS Notebook Server Samples Data' do 
  install_dir node['arcgis']['notebook_server']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  action :post_install
end
