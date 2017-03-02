#
# Cookbook Name:: arcgis-insights
# Recipe:: uninstall
#
# Copyright 2017 Esri
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

arcgis_insights_insights 'Uninstall Insights for ArcGIS' do
  product_code node['arcgis']['insights']['product_code']
  run_as_user node['arcgis']['run_as_user']
  if node['platform'] == 'windows'
    only_if { Utils.product_installed?(node['arcgis']['insights']['product_code']) }
  else
    only_if { ::File.exists?(::File.join(node['arcgis']['server']['install_dir'],
                                        node['arcgis']['server']['install_subdir'],
                                        'GeoEvent/bin/ArcGISGeoEvent-service')) }
  end
  action :uninstall
end
