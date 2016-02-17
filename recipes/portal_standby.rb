#
# Cookbook Name:: arcgis
# Recipe:: portal_standby
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

arcgis_portal 'Portal for ArcGIS system requirements' do
  action :system
end

arcgis_portal 'Setup Portal for ArcGIS' do
  install_dir node['arcgis']['portal']['install_dir']
  data_dir node['arcgis']['portal']['data_dir']
  setup node['arcgis']['portal']['setup']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  action :install
end

arcgis_portal 'Authorize Portal for ArcGIS' do
  authorization_file node['arcgis']['portal']['authorization_file']
  authorization_file_version node['arcgis']['portal']['authorization_file_version']
  action :authorize
end

arcgis_portal 'Join Portal Site' do
  portal_local_url node['arcgis']['portal']['local_url']
  primary_machine_url node['arcgis']['portal']['primary_machine_url']
  username node['arcgis']['portal']['admin_username']
  password node['arcgis']['portal']['admin_password']
  action :join_site
end
