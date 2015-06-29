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

hostsfile_entry "Map portal domain name to localhost" do
  ip_address "127.0.0.1"
  hostname node['portal']['domain_name']
  action :append
end

arcgis_portal "Setup Portal for ArcGIS" do
  install_dir node['portal']['install_dir']
  setup node['portal']['setup']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  action :install
end

arcgis_portal "Authorize Portal for ArcGIS" do
  authorization_file node['portal']['authorization_file']
  authorization_file_version node['portal']['authorization_file_version']
  action :authorize
end

directory node['portal']['content_dir'] do
  owner node['arcgis']['run_as_user']
  if node['platform'] != 'windows'
    group 'root'    
    mode '0755'
  end
  recursive true
  not_if {node['portal']['content_dir'].start_with?("\\\\")}
  action :create
end

arcgis_portal "Create Portal Site" do
  portal_local_url node['portal']['local_url']
  username node['portal']['admin_username']
  password node['portal']['admin_password']
  full_name node['portal']['admin_full_name']
  email node['portal']['admin_email']
  description node['portal']['admin_description']
  security_question node['portal']['security_question']
  security_question_answer node['portal']['security_question_answer']
  install_dir node['portal']['install_dir']
  content_dir node['portal']['content_dir']
  action :create_site
end

