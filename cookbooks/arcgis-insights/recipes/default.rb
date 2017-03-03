#
# Cookbook Name:: arcgis-insights
# Recipe:: default
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

arcgis_insights_insights 'Unpack Insights for ArcGIS' do
  setup_archive node['arcgis']['insights']['setup_archive']
  setups_repo node['arcgis']['repository']['setups']
  run_as_user node['arcgis']['run_as_user']
  only_if { ::File.exist?(node['arcgis']['insights']['setup_archive']) &&
            !::File.exist?(node['arcgis']['insights']['setup']) }
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['insights']['product_code']) }
  else
    not_if { ::File.exists?(::File.join(node['arcgis']['server']['install_dir'],
                                        node['arcgis']['server']['install_subdir'],
                                        'uninstall_Insights.sh')) || 
             ::File.exists?(::File.join(node['arcgis']['portal']['install_dir'],
                                        node['arcgis']['portal']['install_subdir'],
                                        'uninstall_Insights.sh'))}
  end
  action :unpack
end

arcgis_insights_insights 'Setup Insights for ArcGIS' do
  setup node['arcgis']['insights']['setup']
  run_as_user node['arcgis']['run_as_user']
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['insights']['product_code']) }
  else
    not_if { ::File.exists?(::File.join(node['arcgis']['server']['install_dir'],
                                        node['arcgis']['server']['install_subdir'],
                                        'uninstall_Insights.sh')) || 
             ::File.exists?(::File.join(node['arcgis']['portal']['install_dir'],
                                        node['arcgis']['portal']['install_subdir'],
                                        'uninstall_Insights.sh'))}
  end
  action :install
end
