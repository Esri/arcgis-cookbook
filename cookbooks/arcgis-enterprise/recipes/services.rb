#
# Cookbook Name:: arcgis-enterprise
# Recipe:: services
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

node['arcgis']['server']['services'].each do |service|
  arcgis_enterprise_gis_service 'Publish ArcGIS Server service' do
    server_url node['arcgis']['server']['url']
    username node['arcgis']['server']['publisher_username']
    password node['arcgis']['server']['publisher_password']
    folder service['folder']
    name service['name']
    type service['type']
    definition_file service['definition_file']
    properties service['properties']
    action :publish
  end
end