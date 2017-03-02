#
# Cookbook Name:: arcgis-enterprise
# Attributes:: lp-install
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

if node['platform'] == 'windows'
  windows_package 'Install Portal HelpLP' do
    source node['arcgis']['portal']['lp-setup']
    action :install
    only_if Utils.product_installed?(node['arcgis']['portal']['product_code'])
  end
  windows_package 'Install ServerLP' do
    source node['arcgis']['server']['lp-setup']
    action :install
    only_if Utils.product_installed?(node['arcgis']['server']['product_code'])
  end
  windows_package 'Install webadaptorLP' do
    source node['arcgis']['web_adaptor']['lp-setup']
    action :install
    only_if Utils.product_installed?(node['arcgis']['web_adaptor']['product_code'])
  end
  windows_package 'Install Datastore HelpLP' do
    source node['arcgis']['data_store']['lp-setup']
    action :install
  end
else
  package 'Install PortalLP' do
    source node['arcgis']['portal']['lp-setup']
    action :install
  end
  package 'Install ServerLP' do
    source node['arcgis']['server']['lp-setup']
    action :install
  end
end
