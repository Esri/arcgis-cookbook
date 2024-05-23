#
# Cookbook Name:: arcgis-enterprise
# Recipe:: webgisdr_export
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

# Mixlib::ShellOut requies SeBatchLogonRight privilege to execute batch files
# under ArcGIS user account.
windows_user_privilege 'Grant ArcGIS user SeBatchLogonRight privilege' do
  privilege 'SeBatchLogonRight'
  principal node['arcgis']['run_as_user']
  only_if { node['platform'] == 'windows' }
  action :add
end

arcgis_enterprise_portal 'Create ArcGIS Enterprise backup' do
  install_dir node['arcgis']['portal']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  webgisdr_properties node['arcgis']['portal']['webgisdr_properties']
  webgisdr_timeout node['arcgis']['portal']['webgisdr_timeout']
  action :webgisdr_export
end
  