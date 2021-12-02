#
# Cookbook Name:: arcgis-geoevent
# Recipe:: admin_reset
#
# Copyright 2021 Esri
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

# Stop the ArcGIS GeoEvent Server and GeoEvent Gateway Windows services.

if node['platform'] == 'windows'
  arcgis_geoevent_geoevent 'Stop ArcGIS GeoEvent Server' do
    install_dir node['arcgis']['server']['install_dir']
    action :stop
  end

  # Locate and delete the files and folders beneath the following directories
  # (leaving the parent folders intact):

  [
    ::File.join(node['arcgis']['server']['install_dir'],'GeoEvent\\data'),
    ::File.join(node['arcgis']['server']['install_dir'],'gateway\\log'),
    ::File.join(ENV['ProgramData'], 'Esri\\GeoEvent'),
    ::File.join(ENV['ProgramData'], 'Esri\\GeoEvent-Gateway\\zookeeper-data'),
    ::File.join(ENV['ProgramData'], 'Esri\\GeoEvent-Gateway\\kafka\\logs'),
    ::File.join(ENV['ProgramData'], 'Esri\\GeoEvent-Gateway\\kafka\\logs1'),
    ::File.join(ENV['ProgramData'], 'Esri\\GeoEvent-Gateway\\kafka\\logs2')
  ].each do |dir|
    directory dir do
      recursive true
      rights :full_control, node['arcgis']['run_as_user']
      inherits true
      action [:delete, :create]
    end
  end

  # Delete the GeoEvent Gateway configuration file (a new file will be rebuilt).

  file ::File.join(node['arcgis']['server']['install_dir'], 
                  'GeoEvent\\etc\\com.esri.ges.gateway.cfg') do
    action :delete
  end

  # Start the ArcGIS GeoEvent Server Windows services.

  arcgis_geoevent_geoevent 'Start ArcGIS GeoEvent Server' do
    install_dir node['arcgis']['server']['install_dir']
    action :start
  end
else
  Chef:Log.warn("Recipe is not supported on #{node['platform']} platform.")
end