#
# Cookbook Name:: arcgis
# Recipe:: all_installed
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

arcgis_desktop 'Install ArcGIS for Desktop' do
  setup node['arcgis']['desktop']['setup']
  install_dir node['arcgis']['desktop']['install_dir']
  python_dir node['arcgis']['python']['install_dir']
  install_features node['arcgis']['desktop']['install_features']
  esri_license_host node['arcgis']['desktop']['esri_license_host']
  software_class node['arcgis']['desktop']['software_class']
  seat_preference node['arcgis']['desktop']['seat_preference']
  desktop_config node['arcgis']['desktop']['desktop_config']
  modifyflexdacl node['arcgis']['desktop']['modifyflexdacl']
  action :install
end

arcgis_licensemanager 'Install ArcGIS for License Manager' do
  setup node['arcgis']['licensemanager']['setup']
  install_dir node['arcgis']['licensemanager']['install_dir']
  python_dir node['arcgis']['python']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  action :install
end

arcgis_server 'Install ArcGIS for Server' do
  setup node['arcgis']['server']['setup']
  install_dir node['arcgis']['server']['install_dir']
  python_dir node['arcgis']['python']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  action :install
end

arcgis_datastore 'Install ArcGIS DataStore' do
  setup node['arcgis']['data_store']['setup']
  install_dir node['arcgis']['data_store']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  action :install
end

arcgis_portal 'Install Portal for ArcGIS' do
  install_dir node['arcgis']['portal']['install_dir']
  setup node['arcgis']['portal']['setup']
  content_dir node['arcgis']['portal']['content_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  action :install
end

arcgis_webadaptor 'Install Web Adaptor for Server' do
  install_dir node['arcgis']['web_adaptor']['install_dir']
  setup node['arcgis']['web_adaptor']['setup']
  instance_name node['arcgis']['server']['wa_name']
  action :install
end

arcgis_webadaptor 'Install Web Adaptor for Portal' do
  install_dir node['arcgis']['web_adaptor']['install_dir']
  setup node['arcgis']['web_adaptor']['setup']
  instance_name node['arcgis']['portal']['wa_name']
  action :install
end
