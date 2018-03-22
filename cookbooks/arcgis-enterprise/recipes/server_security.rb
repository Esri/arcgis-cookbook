#
# Cookbook Name:: arcgis-enterprise
# Recipe:: server_security
#
# Copyright 2017 Esri
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

arcgis_enterprise_server 'Configure ArcGIS Server identity store' do
  server_url node['arcgis']['server']['url']
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  user_store_config node['arcgis']['server']['security']['user_store_config']
  role_store_config node['arcgis']['server']['security']['role_store_config']
  action :set_identity_store
end

arcgis_enterprise_server 'Assign privileges to ArcGIS Server roles' do
  server_url node['arcgis']['server']['url']
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  privileges node['arcgis']['server']['security']['privileges']
  action :assign_privileges
end