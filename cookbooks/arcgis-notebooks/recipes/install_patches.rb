#
# Cookbook Name:: arcgis-notebooks
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

# Install ArcGIS Notebook Server patches

arcgis_notebooks_server 'Stop ArcGIS Notebook Server before patching' do
  install_dir node['arcgis']['notebook_server']['install_dir']
  not_if { node['arcgis']['notebook_server']['patches'].empty?}
  action :stop
end

node['arcgis']['notebook_server']['patches'].each do |patch|
  arcgis_enterprise_patches "Install patch #{patch}" do
    product 'notebookserver'
    patch_folder node['arcgis']['repository']['patches']
    patch patch
    run_as_user node['arcgis']['run_as_user']
    action :install
  end
end

arcgis_notebooks_server 'Start ArcGIS Notebook Server after patching' do
  install_dir node['arcgis']['notebook_server']['install_dir']
  not_if { node['arcgis']['notebook_server']['patches'].empty?}
  action :start
end