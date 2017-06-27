#
# Cookbook Name:: arcgis-enterprise
# Recipe:: clean
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

[ node['arcgis']['server']['directories_root'],
  node['arcgis']['portal']['data_dir'],
  node['arcgis']['data_store']['data_dir'] ].each do |dir|
  directory dir do
    recursive true
    action :delete
  end
end

if node['platform'] == 'windows'
  directory node['arcgis']['server']['install_dir'] do
    recursive true
    not_if { Utils.product_installed?(node['arcgis']['server']['product_code']) ||
             node['arcgis']['server']['install_dir'] == 'C:\\ArcGIS' }
    action :delete
  end

  directory node['arcgis']['portal']['install_dir'] do
    recursive true
    not_if { Utils.product_installed?(node['arcgis']['portal']['product_code']) }
    action :delete
  end

  directory node['arcgis']['data_store']['install_dir'] do
    recursive true
    not_if { Utils.product_installed?(node['arcgis']['data_store']['product_code']) }
    action :delete
  end
end
