#
# Cookbook Name:: arcgis
# Recipe:: server_node
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

arcgis_server 'ArcGIS for Server system requirements' do
  action :system
end

arcgis_server 'Setup ArcGIS for Server' do
  setup node['arcgis']['server']['setup']
  install_dir node['arcgis']['server']['install_dir']
  python_dir node['arcgis']['python']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  action :install
end

arcgis_server 'Authorize ArcGIS for Server' do
  authorization_file node['arcgis']['server']['authorization_file']
  authorization_file_version node['arcgis']['server']['authorization_file_version']
  action :authorize
end

arcgis_server 'Join ArcGIS for Server Site' do
  server_url node['arcgis']['server']['local_url']
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  primary_server_url node['arcgis']['server']['primary_server_url']
  retries 10
  retry_delay 30
  action :join_site
end

arcgis_server 'Add machine to default cluster' do
  server_url node['arcgis']['server']['local_url']
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  cluster 'default'
  retries 10
  retry_delay 30
  action :join_cluster
end

arcgis_server 'Configure HTTPS' do
  server_url node['arcgis']['server']['local_url']
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  keystore_file node['arcgis']['server']['keystore_file']
  keystore_password node['arcgis']['server']['keystore_password']
  cert_alias node['arcgis']['server']['cert_alias']
  not_if { node['arcgis']['server']['keystore_file'].nil? }
  action :configure_https
end
