#
# Cookbook Name:: arcgis-notebooks
# Recipe:: install_server
#
# Copyright 2019-2021 Esri
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

if node['platform'] == 'windows'
  arcgis_notebooks_server 'Update ArcGIS Notebook Server service logon account' do
    install_dir node['arcgis']['notebook_server']['install_dir']
    run_as_user node['arcgis']['run_as_user']
    run_as_password node['arcgis']['run_as_password']
    not_if { node['arcgis']['run_as_msa'] }
    only_if { Utils.product_installed?(node['arcgis']['notebook_server']['product_code']) }
    action :update_account
  end
end

arcgis_notebooks_server "Install System Requirements:#{recipe_name}" do
  action :system
  only_if { node['arcgis']['notebook_server']['install_system_requirements'] }
end

arcgis_notebooks_server 'Unpack ArcGIS Notebook Server Setup' do
  setup_archive node['arcgis']['notebook_server']['setup_archive']
  setups_repo node['arcgis']['repository']['setups']
  run_as_user node['arcgis']['run_as_user']
  only_if { ::File.exist?(node['arcgis']['notebook_server']['setup_archive']) &&
            !::File.exist?(node['arcgis']['notebook_server']['setup']) }
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['notebook_server']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                               node['hostname'],
                                               node['arcgis']['version'],
                                               :ArcGISNotebookServer) }
  end
  action :unpack
end

# Uninstall previous version of ArcGIS Notebook Server Samples Data.
['10.9.1', '11.0', '11.1', '11.2', '11.3'].each do |samples_data_version|
  arcgis_notebooks_data 'Uninstall ArcGIS Notebook Server Samples Data' do
    install_dir node['arcgis']['notebook_server']['install_dir']
    run_as_user node['arcgis']['run_as_user']
    not_if { node['platform'] == 'windows' }
    not_if { samples_data_version == node['arcgis']['version'] }
    only_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                                node['hostname'],
                                                samples_data_version,
                                                :ArcGISNotebookServer_ArcGISNotebookServerSamplesData) }
    action :uninstall
  end 
end

arcgis_notebooks_server 'Setup ArcGIS Notebook Server' do
  setup node['arcgis']['notebook_server']['setup']
  install_dir node['arcgis']['notebook_server']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  run_as_msa node['arcgis']['run_as_msa']
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['notebook_server']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                               node['hostname'],
                                               node['arcgis']['version'],
                                               :ArcGISNotebookServer) }
  end
  action :install
end

arcgis_notebooks_server 'Run postinstallation utility for standard images' do 
  install_dir node['arcgis']['notebook_server']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  docker_images node['arcgis']['notebook_server']['standard_images']
  action :post_install
end

arcgis_notebooks_server 'Run postinstallation utility for advanced images' do 
  install_dir node['arcgis']['notebook_server']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  docker_images node['arcgis']['notebook_server']['advanced_images']
  only_if { node['arcgis']['notebook_server']['license_level'] == 'advanced' }
  action :post_install
end

arcgis_notebooks_server 'Configure agsnotebook service' do
  install_dir node['arcgis']['notebook_server']['install_dir']
  only_if { node['arcgis']['notebook_server']['configure_autostart'] }
  action :configure_autostart
end
