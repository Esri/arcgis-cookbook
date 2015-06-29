#
# Cookbook Name:: arcgis
# Recipe:: webadaptor
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

arcgis_portal "Register Server" do
  portal_url node['portal']['url']
  username node['portal']['admin_username']
  password node['portal']['admin_password']
  server_url node['server']['url']
  is_hosted true
  action :register_server
end

arcgis_server "Federate Server" do
  portal_url node['portal']['url']
  portal_username node['portal']['admin_username']
  portal_password node['portal']['admin_password']
  server_url node['server']['url']
  server_id node['server']['server_id']
  secret_key node['server']['secret_key']
  username node['server']['admin_username']
  password node['server']['admin_password']
  action :federate
end