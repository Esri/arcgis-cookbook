#
# Cookbook Name:: arcgis-enterprise
# Recipe:: install_server
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

if node['platform'] == 'windows'
  arcgis_enterprise_server 'Update ArcGIS Server service logon account' do
    install_dir node['arcgis']['server']['install_dir']
    run_as_user node['arcgis']['run_as_user']
    run_as_password node['arcgis']['run_as_password']
    only_if { Utils.product_installed?(node['arcgis']['server']['product_code']) }
    subscribes :update_account, "user[#{node['arcgis']['run_as_user']}]", :immediately
    action :nothing
  end
end

arcgis_enterprise_server "Install System Requirements:#{recipe_name}" do
  action :system
  only_if { node['arcgis']['server']['install_system_requirements'] }
end

arcgis_enterprise_server 'Unpack ArcGIS Server Setup' do
  setup_archive node['arcgis']['server']['setup_archive']
  setups_repo node['arcgis']['repository']['setups']
  run_as_user node['arcgis']['run_as_user']
  only_if { ::File.exist?(node['arcgis']['server']['setup_archive']) &&
            !::File.exist?(node['arcgis']['server']['setup']) }
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['server']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                               node['hostname'],
                                               node['arcgis']['version'],
                                               :ArcGISServer) }
  end
  action :unpack
end

arcgis_enterprise_server 'Setup ArcGIS Server' do
  setup node['arcgis']['server']['setup']
  install_dir node['arcgis']['server']['install_dir']
  python_dir node['arcgis']['python']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['server']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                               node['hostname'],
                                               node['arcgis']['version'],
                                               :ArcGISServer) }
  end
  action :install
end

arcgis_enterprise_server 'Configure arcgisserver service' do
  install_dir node['arcgis']['server']['install_dir']
  only_if { node['arcgis']['server']['configure_autostart'] }
  action :configure_autostart
end
