#
# Cookbook Name:: arcgis-mission
# Recipe:: uninstall_server
#
# Copyright 2021 Esri
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

arcgis_mission_server 'Uninstall ArcGIS Mission Server' do
    install_dir node['arcgis']['mission_server']['install_dir']
    run_as_user node['arcgis']['run_as_user']
    if node['platform'] == 'windows'
        product_code node['arcgis']['mission_server']['product_code']
        only_if { Utils.product_installed?(node['arcgis']['mission_server']['product_code']) }
    else
        only_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                                    node['hostname'],
                                                    node['arcgis']['version'],
                                                    :ArcGISMissionServer) }
    end
    action :uninstall
end
