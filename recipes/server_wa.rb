#
# Cookbook Name:: arcgis
# Recipe:: server_wa
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

arcgis_webadaptor 'ArcGIS Web Adaptor system requirements - server' do
  action :system
end

arcgis_webadaptor 'Setup Web Adaptor for Server' do
  install_dir node['arcgis']['web_adaptor']['install_dir']
  setup node['arcgis']['web_adaptor']['setup']
  instance_name node['arcgis']['server']['wa_name']
  action :install
end

arcgis_webadaptor 'Configure Web Adaptor with Server' do
  install_dir node['arcgis']['web_adaptor']['install_dir']
  server_url node['arcgis']['server']['url']
  server_local_url node['arcgis']['server']['local_url']
  #server_local_url 'http://' + node['ipaddress'] + ':6080'
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  admin_access node['arcgis']['web_adaptor']['admin_access']
  action :configure_with_server
end
