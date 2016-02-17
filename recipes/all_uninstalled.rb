#
# Cookbook Name:: arcgis
# Recipe:: all_uninstalled
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

arcgis_webadaptor 'Uninstall Web Adaptor for Portal' do
  install_dir node['arcgis']['web_adaptor']['install_dir']
  product_code node['arcgis']['web_adaptor']['product_code2']
  action :uninstall
end

arcgis_webadaptor 'Uninstall Web Adaptor for Server' do
  install_dir node['arcgis']['web_adaptor']['install_dir']
  product_code node['arcgis']['web_adaptor']['product_code']
  action :uninstall
end

arcgis_portal 'Uninstall Portal for ArcGIS' do
  install_dir node['arcgis']['portal']['install_dir']
  product_code node['arcgis']['portal']['product_code']
  action :uninstall
end

arcgis_datastore 'Uninstall ArcGIS DataStore' do
  install_dir node['arcgis']['data_store']['install_dir']
  product_code node['arcgis']['data_store']['product_code']
  action :uninstall
end

arcgis_geoevent 'Uninstall ArcGIS GeoEvent Extension for Server' do
  install_dir node['arcgis']['server']['install_dir']
  product_code node['arcgis']['geoevent']['product_code']
  action :uninstall
end

arcgis_server 'Uninstall ArcGIS for Server' do
  install_dir node['arcgis']['server']['install_dir']
  product_code node['arcgis']['server']['product_code']
  action :uninstall
end

arcgis_licensemanager 'Install ArcGIS for License Manager' do
  install_dir node['arcgis']['licensemanager']['install_dir']
  product_code node['arcgis']['licensemanager']['product_code']
  action :uninstall
end

arcgis_desktop 'Install ArcGIS for Desktop' do
  install_dir node['arcgis']['desktop']['install_dir']
  product_code node['arcgis']['desktop']['product_code']
  action :uninstall
end
