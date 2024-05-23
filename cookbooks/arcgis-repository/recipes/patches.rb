#
# Cookbook:: arcgis-repository
# Recipe:: patches
#
# Copyright 2022-2024 Esri
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

# Create archives directory
directory node['arcgis']['repository']['local_patches'] do
  mode '0755' if node['platform'] != 'windows'
  recursive true
  action :create
end

arcgis_repository_patches 'Download ArcGIS patches from remote repository' do
  patches_url node['arcgis']['repository']['patch_notification']['url']
  products node['arcgis']['repository']['patch_notification']['products']
  versions node['arcgis']['repository']['patch_notification']['versions']
  patches_dir node['arcgis']['repository']['local_patches']
  action :download
end
