#
# Cookbook Name:: arcgis-enterprise
# Recipe:: unregister_portal_machine
#
# Copyright 2024 Esri
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

# Unregisters the local machine from the Portal for ArcGIS
arcgis_enterprise_portal 'Unregister portal machine' do
  portal_url node['arcgis']['portal']['url']
  username node['arcgis']['portal']['admin_username']
  password node['arcgis']['portal']['admin_password']
  action :unregister_machine
end
