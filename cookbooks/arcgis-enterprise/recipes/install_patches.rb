#
# Cookbook Name:: arcgis-enterprise
# Recipe:: install_patches
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

# Install Portal for ArcGIS patches

arcgis_enterprise_portal 'Stop Portal for ArcGIS before patching' do
  tomcat_java_opts node['arcgis']['portal']['tomcat_java_opts']
  not_if { node['arcgis']['portal']['patches'].empty? }
  only_if { node['arcgis']['portal']['configure_autostart'] }
  action :stop
end

# The Portal for ArcGIS Validation and Repair tool must be run on all 
# 11.1, 10.9.1 and 10.8.1 machines with Portal for ArcGIS installed.
# This tool is not available on Linux.
execute "Run Portal for ArcGIS Validation and Repair tool" do
  command "\"#{node['arcgis']['portal']['repair_tool']}\" /silent /repair"
  timeout 14400
  only_if { node['platform'] == 'windows' &&
            !node['arcgis']['portal']['repair_tool'].nil? &&
            Utils.product_installed?(node['arcgis']['portal']['product_code']) }
end

node['arcgis']['portal']['patches'].each do |patch|
  arcgis_enterprise_patches "Install patch #{patch}" do
    product 'portal'
    patch_folder node['arcgis']['repository']['patches']
    patch patch
    run_as_user node['arcgis']['run_as_user']
    if node['platform'] == 'windows'
      patch_registry node['arcgis']['portal']['patch_registry']
    else
      patch_log node['arcgis']['portal']['patch_log']
    end

    action :install
  end
end

arcgis_enterprise_portal 'Start Portal for ArcGIS after patching' do
  tomcat_java_opts node['arcgis']['portal']['tomcat_java_opts']
  not_if { node['arcgis']['portal']['patches'].empty? }
  only_if { node['arcgis']['portal']['configure_autostart'] }
  action :start
end

# Install ArcGIS Server patches

arcgis_enterprise_server 'Stop ArcGIS Server before patching' do
  not_if { node['arcgis']['server']['patches'].empty? }
  only_if { node['arcgis']['server']['configure_autostart'] }
  action :stop
end

node['arcgis']['server']['patches'].each do |patch|
  arcgis_enterprise_patches "Install patch #{patch}" do
    product 'server'
    patch_folder node['arcgis']['repository']['patches']
    patch patch
    run_as_user node['arcgis']['run_as_user']
    if node['platform'] == 'windows'
      patch_registry node['arcgis']['server']['patch_registry']
    else
      patch_log node['arcgis']['server']['patch_log']
    end
    action :install
  end
end

arcgis_enterprise_server 'Start ArcGIS Server after patching' do
  not_if { node['arcgis']['server']['patches'].empty? }
  only_if { node['arcgis']['server']['configure_autostart'] }
  action :start
end

# Install ArcGIS Data Store patches

arcgis_enterprise_datastore 'Stop ArcGIS Data Store before patching' do
  not_if { node['arcgis']['data_store']['patches'].empty? }
  only_if { node['arcgis']['data_store']['configure_autostart'] }
  action :stop
end

node['arcgis']['data_store']['patches'].each do |patch|
  arcgis_enterprise_patches "Install patch #{patch}" do
    product 'datastore'
    patch_folder node['arcgis']['repository']['patches']
    patch patch
    run_as_user node['arcgis']['run_as_user']
    if node['platform'] == 'windows'
      patch_registry node['arcgis']['data_store']['patch_registry']
    else
      patch_log node['arcgis']['data_store']['patch_log']
    end
    action :install
  end
end

arcgis_enterprise_datastore 'Start ArcGIS Data Store after patching' do
  not_if { node['arcgis']['data_store']['patches'].empty? }
  only_if { node['arcgis']['data_store']['configure_autostart'] }
  action :start
end

# Install ArcGIS Web Adaptor patches

node['arcgis']['web_adaptor']['patches'].each do |patch|
  arcgis_enterprise_patches "Install patch #{patch}" do
    patch_folder node['arcgis']['repository']['patches']
    patch patch
    run_as_user node['arcgis']['run_as_user']
    if node['platform'] == 'windows'
      patch_registry node['arcgis']['web_adaptor']['patch_registry']
    else
      patch_log node['arcgis']['web_adaptor']['patch_log']      
    end
    action :install
  end
end
