#
# Cookbook Name:: arcgis-enterprise
# Recipe:: portal_security
#
# Copyright 2018 Esri
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
arcgis_enterprise_portal 'Configure Portal identity store' do
  portal_url node['arcgis']['portal']['url']
  username node['arcgis']['portal']['admin_username']
  password node['arcgis']['portal']['admin_password']
  user_store_config node['arcgis']['portal']['security']['user_store_config']
  role_store_config node['arcgis']['portal']['security']['role_store_config']
  action :set_identity_store
end