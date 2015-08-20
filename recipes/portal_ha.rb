#
# Cookbook Name:: arcgis
# Recipe:: portal_ha
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

arcgis_portal "Copy Web Adaptors Shared Key" do
  portal_local_url "https://" + node['portal']['domain_name'] + ":7443"  
  peer_machine node['portal']['peer_machine']
  username node['portal']['admin_username']
  password node['portal']['admin_password']
  only_if {!node['portal']['is_primary']}
  action :copy_wa_shared_key
end

arcgis_portal "Configure HA" do
  install_dir node['portal']['install_dir']
  content_dir node['portal']['content_dir']
  portal_url node['portal']['url']
  portal_local_url "https://" + node['portal']['domain_name'] + ":7443"
  peer_machine node['portal']['peer_machine'] 
  action :configure_ha
end