#
# Cookbook Name:: arcgis-notebooks
# Recipe:: server_wa
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

include_recipe 'arcgis-notebooks::install_server_wa'

arcgis_enterprise_webadaptor 'Configure Web Adaptor with Notebook Server' do
  install_dir node['arcgis']['web_adaptor']['install_dir']
  server_wa_url node['arcgis']['notebook_server']['wa_url']
  server_url node['arcgis']['notebook_server']['url']
  username node['arcgis']['notebook_server']['admin_username']
  password node['arcgis']['notebook_server']['admin_password']
  admin_access true
  mode node['arcgis']['version'] == '10.7.1' ? 'server' : 'notebook'
  retries 5
  retry_delay 60
  action :configure_with_server
end
