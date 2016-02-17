#
# Cookbook Name:: arcgis
# Recipe:: system
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

chef_gem 'multipart-post' do
  ignore_failure true
end

arcgis_server 'Verify ArcGIS for Server system requirements' do
  action :system
end

arcgis_datastore 'Verify ArcGIS DataStore system requirements' do
  action :system
end

arcgis_portal 'Verify Portal for ArcGIS system requirements' do
  action :system
end

arcgis_webadaptor 'Verify ArcGIS Web Adaptor system requirements' do
  action :system
end

include_recipe 'arcgis::hosts'
