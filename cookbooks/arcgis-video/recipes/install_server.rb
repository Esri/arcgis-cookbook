#
# Cookbook Name:: arcgis-video
# Recipe:: install_server
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
#

if node['platform'] == 'windows'
  arcgis_video_server 'Update ArcGIS Video Server service logon account' do
    install_dir node['arcgis']['video_server']['install_dir']
    run_as_user node['arcgis']['run_as_user']
    run_as_password node['arcgis']['run_as_password']
    not_if { node['arcgis']['run_as_msa'] }
    only_if { Utils.product_installed?(node['arcgis']['video_server']['product_code']) }
    action :update_account
  end
end

arcgis_video_server "Install System Requirements:#{recipe_name}" do
  action :system
  only_if { node['arcgis']['video_server']['install_system_requirements'] }
end

arcgis_video_server 'Unpack ArcGIS Video Server Setup' do
  setup_archive node['arcgis']['video_server']['setup_archive']
  setups_repo node['arcgis']['repository']['setups']
  run_as_user node['arcgis']['run_as_user']
  only_if { ::File.exist?(node['arcgis']['video_server']['setup_archive']) &&
            !::File.exist?(node['arcgis']['video_server']['setup']) }
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['video_server']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                               node['hostname'],
                                               node['arcgis']['version'],
                                               :ArcGISVideoServer) }
  end
  action :unpack
end

arcgis_video_server 'Setup ArcGIS Video Server' do
  setup node['arcgis']['video_server']['setup']
  install_dir node['arcgis']['video_server']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  run_as_msa node['arcgis']['run_as_msa']
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['video_server']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                               node['hostname'],
                                               node['arcgis']['version'],
                                               :ArcGISVideoServer) }
  end
  action :install
end

arcgis_video_server 'Configure agsvideo service' do
  install_dir node['arcgis']['video_server']['install_dir']
  only_if { node['arcgis']['video_server']['configure_autostart'] }
  action :configure_autostart
end
