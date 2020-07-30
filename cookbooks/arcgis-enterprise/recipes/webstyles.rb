#
# Cookbook Name:: arcgis-enterprise
# Recipe:: webstyles
#
# Copyright 2018 Esri
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

arcgis_enterprise_webstyles 'Unpack ArcGIS Web Styles' do
  setup_archive node['arcgis']['webstyles']['setup_archive']
  setups_repo node['arcgis']['repository']['setups']
  run_as_user node['arcgis']['run_as_user']
  only_if { ::File.exist?(node['arcgis']['webstyles']['setup_archive']) &&
            !::File.exist?(node['arcgis']['webstyles']['setup']) }
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['webstyles']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                                node['hostname'],
                                                node['arcgis']['version'],
                                                :ArcGISPortal_WebStyles) }
  end
  action :unpack
end

arcgis_enterprise_webstyles 'Install ArcGIS Web Styles' do
  product_code node['arcgis']['webstyles']['product_code']
  setup node['arcgis']['webstyles']['setup']
  setup_options node['arcgis']['webstyles']['setup_options']
  run_as_user node['arcgis']['run_as_user']
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['webstyles']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                                node['hostname'],
                                                node['arcgis']['version'],
                                                :ArcGISPortal_WebStyles) }
  end
  action :install
end

arcgis_enterprise_portal 'Start Portal for ArcGIS after Web Styles install' do
  tomcat_java_opts node['arcgis']['portal']['tomcat_java_opts']
  action :start
end
