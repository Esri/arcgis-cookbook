#
# Cookbook Name:: arcgis-geoevent
# Recipe:: default
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

arcgis_geoevent_geoevent 'Validate ArcGIS GeoEvent Server system requirements' do
  action :system
end

arcgis_geoevent_geoevent 'Authorize ArcGIS GeoEvent Server' do
  authorization_file node['arcgis']['geoevent']['authorization_file']
  authorization_file_version node['arcgis']['geoevent']['authorization_file_version']
  retries 5
  retry_delay 60
  not_if { node['arcgis']['geoevent']['authorization_file'] == '' ||
           node['arcgis']['cache_authorization_files'] &&
           ::File.exists?(node['arcgis']['geoevent']['cached_authorization_file']) &&
           FileUtils.compare_file(node['arcgis']['geoevent']['authorization_file'],
                                  node['arcgis']['geoevent']['cached_authorization_file']) }
  action :authorize
end

file node['arcgis']['geoevent']['cached_authorization_file'] do
  if ::File.exists?(node['arcgis']['geoevent']['authorization_file'])
    content File.open(node['arcgis']['geoevent']['authorization_file'], 'rb') { |file| file.read }
  end
  sensitive true
  subscribes :create, 'arcgis_geoevent_geoevent[Authorize ArcGIS GeoEvent Server]', :immediately
  only_if { node['arcgis']['cache_authorization_files'] }
  action :nothing
end

if node['platform'] == 'windows'
  arcgis_geoevent_geoevent 'Update ArcGISGeoEvent service logon account' do
    run_as_user node['arcgis']['run_as_user']
    run_as_password node['arcgis']['run_as_password']
    not_if { node['arcgis']['run_as_msa'] }
    only_if { Utils.product_installed?(node['arcgis']['geoevent']['product_code']) }
    action :update_account
  end
end

arcgis_geoevent_geoevent 'Unpack ArcGIS GeoEvent Server Setup' do
  setup_archive node['arcgis']['geoevent']['setup_archive']
  setups_repo node['arcgis']['repository']['setups']
  run_as_user node['arcgis']['run_as_user']
  only_if { ::File.exist?(node['arcgis']['geoevent']['setup_archive']) &&
            !::File.exist?(node['arcgis']['geoevent']['setup']) }
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['geoevent']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                               node['hostname'],
                                               node['arcgis']['version'],
                                               :ArcGISGeoEvent) }
  end
  action :unpack
end

arcgis_geoevent_geoevent 'Setup ArcGIS GeoEvent Server' do
  setup node['arcgis']['geoevent']['setup']
  product_code node['arcgis']['geoevent']['product_code']
  install_dir node['arcgis']['server']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  run_as_msa node['arcgis']['run_as_msa']
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['geoevent']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                                node['hostname'],
                                                node['arcgis']['version'],
                                                :ArcGISGeoEvent) }
  end
  action :install
end

arcgis_geoevent_geoevent 'Configure ArcGISGeoEvent service' do
  install_dir node['arcgis']['server']['install_dir']
  only_if { node['arcgis']['geoevent']['configure_autostart'] }
  action :configure_autostart  
end

arcgis_geoevent_geoevent 'Stop ArcGIS GeoEvent Server' do
  install_dir node['arcgis']['server']['install_dir']
  action :stop
end

if node['platform'] == 'windows'
  # Remove everything under C:\ProgramData\Esri\GeoEvent-Gateway before starting GeoEvent.
  directory "#{ENV['ProgramData']}\\Esri\\GeoEvent-Gateway" do
    recursive true
    action :delete
  end

  directory "#{ENV['ProgramData']}\\Esri\\GeoEvent-Gateway" do
    action :create
  end
end

arcgis_geoevent_geoevent 'Start ArcGIS GeoEvent Server' do
  install_dir node['arcgis']['server']['install_dir']
  action :start
end
