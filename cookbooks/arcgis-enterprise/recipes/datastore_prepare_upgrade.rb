#
# Cookbook Name:: arcgis-enterprise
# Recipe:: datastore_prepare_upgrade
#
# Copyright 2019 Esri
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

# BDS upgrade fails when setup is running under local system account
# because it cannot access C:\Windows\System32\config\systemprofile\AppData\Local.
# tools/prepareupgrade.bat is used to workaround this problem.

file 'Prepare Data Store upgrade' do
  path ::File.join(node['arcgis']['data_store']['install_dir'], 'etc', 'upgrade.txt')
  content ''
end

# arcgis_enterprise_datastore 'Prepare Data Store upgrade' do
#   install_dir node['arcgis']['data_store']['install_dir']
#   data_dir node['arcgis']['data_store']['data_dir']
#   types node['arcgis']['data_store']['types']
#   server_url node['arcgis']['server']['private_url']
#   username node['arcgis']['server']['admin_username']
#   password node['arcgis']['server']['admin_password']
#   action :prepare_upgrade
# end
