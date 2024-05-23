#
# Cookbook Name:: arcgis-video
# Recipe:: unregister_server_wa
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

arcgis_video_server 'Unregister ArcGIS Video Server Web Adaptors' do
  server_url node['arcgis']['video_server']['url']
  username node['arcgis']['video_server']['admin_username']
  password node['arcgis']['video_server']['admin_password']
  action :unregister_web_adaptors
end
