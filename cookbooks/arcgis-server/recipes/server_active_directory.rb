#
# Cookbook Name:: arcgis-server
# Recipe:: server_active_directory
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

if node['platform'] == 'windows'
  arcgis_server_server 'Couple ArcGIS Server with Active Directory' do
    server_url node['arcgis']['server']['url']
    username node['arcgis']['server']['admin_username']
    password node['arcgis']['server']['admin_password']
    active_directory_username node['arcgis']['server']['active_directory_username']
    active_directory_password node['arcgis']['server']['active_directory_password']
    only_if { node['arcgis']['server']['configure_active_directory'] }
    action :set_identity_store_to_windows
  end
  
  arcgis_server_server 'Assign ArcGIS Server roles to Active Directory groups' do
    server_url node['arcgis']['server']['url']
    username node['arcgis']['server']['admin_username']
    password node['arcgis']['server']['admin_password']
    roles_administer node['arcgis']['server']['active_directory_groups_administer']
    roles_publisher node['arcgis']['server']['active_directory_groups_publisher']
    only_if { node['arcgis']['server']['configure_active_directory'] }
    action :assign_privileges
  end
end
