#
# Cookbook Name:: arcgis-geoevent
# Recipe:: default
#
# Copyright 2015 Esri
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
  not_if { ::File.exists?(node['arcgis']['geoevent']['cached_authorization_file']) &&
           FileUtils.compare_file(node['arcgis']['geoevent']['authorization_file'],
                                  node['arcgis']['geoevent']['cached_authorization_file']) }
  action :authorize
end

file node['arcgis']['geoevent']['cached_authorization_file'] do
  content File.open(node['arcgis']['geoevent']['authorization_file'], 'rb') { |file| file.read }
  sensitive true
  subscribes :create, 'arcgis_geoevent_geoevent[Authorize ArcGIS GeoEvent Server]', :immediately
  action :nothing
end

if node['platform'] == 'windows'
  arcgis_geoevent_geoevent 'Update ArcGISGeoEvent service logon account' do
    run_as_user node['arcgis']['run_as_user']
    run_as_password node['arcgis']['run_as_password']
    only_if { Utils.product_installed?(node['arcgis']['geoevent']['product_code']) }
    action :update_account #TODO: trigger update_account only when arcgis user account is updated
  end
end

arcgis_geoevent_geoevent 'Setup ArcGIS GeoEvent Server' do
  setup node['arcgis']['geoevent']['setup']
  product_code node['arcgis']['geoevent']['product_code']
  install_dir node['arcgis']['server']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
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
  action :configure_autostart
  only_if { node['arcgis']['geoevent']['configure_autostart'] }
end

arcgis_geoevent_geoevent 'Start ArcGIS GeoEvent' do
  install_dir node['arcgis']['server']['install_dir']
  action :start
end
