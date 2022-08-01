#
# Cookbook Name:: arcgis-mission
# Recipe:: install_patches
#
# Copyright 2022 Esri
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

# Install ArcGIS Mission Server patches

arcgis_mission_server 'Stop ArcGIS Mission Server before patching' do
  not_if { node['arcgis']['mission_server']['patches'].empty? }
  only_if { node['arcgis']['mission_server']['configure_autostart'] } 
  action :stop
end

node['arcgis']['mission_server']['patches'].each do |patch|
  arcgis_enterprise_patches "Install patch #{patch}" do
    product 'missionserver'
    patch_folder node['arcgis']['repository']['patches']
    patch patch
    run_as_user node['arcgis']['run_as_user']
    action :install
  end
end

arcgis_mission_server 'Start ArcGIS Mission Server after patching' do
  not_if { node['arcgis']['mission_server']['patches'].empty? }
  only_if { node['arcgis']['mission_server']['configure_autostart'] } 
  action :start
end
