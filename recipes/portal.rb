#
# Cookbook Name:: arcgis
# Recipe:: portal
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

# Create Site
arcgis_portal 'Create Portal Site' do
  portal_local_url node['arcgis']['portal']['local_url']
  portal_private_url node['arcgis']['portal']['private_url']
  web_context_url node['arcgis']['portal']['web_context_url']
  username node['arcgis']['portal']['admin_username']
  password node['arcgis']['portal']['admin_password']
  full_name node['arcgis']['portal']['admin_full_name']
  email node['arcgis']['portal']['admin_email']
  description node['arcgis']['portal']['admin_description']
  security_question node['arcgis']['portal']['security_question']
  security_question_answer node['arcgis']['portal']['security_question_answer']
  install_dir node['arcgis']['portal']['install_dir']
  content_dir node['arcgis']['portal']['content_dir']
  action :create_site
end

arcgis_portal 'Configure HTTPS' do
  portal_url node['arcgis']['portal']['local_url']
  username node['arcgis']['portal']['admin_username']
  password node['arcgis']['portal']['admin_password']
  keystore_file node['arcgis']['portal']['keystore_file']
  keystore_password node['arcgis']['portal']['keystore_password']
  cert_alias node['arcgis']['portal']['cert_alias']
  not_if { node['arcgis']['portal']['keystore_file'].nil? }
  action :configure_https
end