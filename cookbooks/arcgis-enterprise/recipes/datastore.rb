#
# Cookbook Name:: arcgis-enterprise
# Recipe:: datastore
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

directory node['arcgis']['data_store']['data_dir'] do
  owner node['arcgis']['run_as_user']
  if node['platform'] != 'windows'
    mode '0700'
  end
  recursive true
  action :create
end

directory node['arcgis']['data_store']['backup_dir'] do
  owner node['arcgis']['run_as_user']
  if node['platform'] != 'windows'
    mode '0700'
  end
  recursive true
  not_if { node['arcgis']['data_store']['backup_dir'].start_with?('\\\\') ||
           node['arcgis']['data_store']['backup_dir'].start_with?('/net/') }
  action :create
end

if node['platform'] == 'windows'
  arcgis_enterprise_datastore 'Update ArcGIS Data Store service logon account' do
    install_dir node['arcgis']['data_store']['install_dir']
    run_as_user node['arcgis']['run_as_user']
    run_as_password node['arcgis']['run_as_password']
    only_if { Utils.product_installed?(node['arcgis']['data_store']['product_code']) }
    subscribes :update_account, "user[#{node['arcgis']['run_as_user']}]", :immediately
    action :nothing
  end
end

arcgis_enterprise_datastore "Install System Requirements:#{recipe_name}" do
  action :system
  only_if { node['arcgis']['data_store']['install_system_requirements'] }
end

arcgis_enterprise_datastore 'Unpack ArcGIS Data Store' do
  setup_archive node['arcgis']['data_store']['setup_archive']
  setups_repo node['arcgis']['repository']['setups']
  run_as_user node['arcgis']['run_as_user']
  only_if { ::File.exist?(node['arcgis']['data_store']['setup_archive']) &&
            !::File.exist?(node['arcgis']['data_store']['setup']) }
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['data_store']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                               node['hostname'],
                                               node['arcgis']['version'],
                                               :ArcGISDataStore) }
  end
  action :unpack
end

arcgis_enterprise_datastore 'Install ArcGIS Data Store' do
  setup node['arcgis']['data_store']['setup']
  product_code node['arcgis']['data_store']['product_code']
  install_dir node['arcgis']['data_store']['install_dir']
  data_dir node['arcgis']['data_store']['data_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['data_store']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                               node['hostname'],
                                               node['arcgis']['version'],
                                               :ArcGISDataStore) }
  end
  action :install
end

arcgis_enterprise_datastore 'Configure arcgisdatastore service' do
  install_dir node['arcgis']['data_store']['install_dir']
  only_if { node['arcgis']['data_store']['configure_autostart'] }
  action :configure_autostart
end

arcgis_enterprise_datastore 'Start ArcGIS Data Store' do
  action :start
end

arcgis_enterprise_datastore 'Configure ArcGIS Data Store' do
  install_dir node['arcgis']['data_store']['install_dir']
  data_dir node['arcgis']['data_store']['data_dir']
  types node['arcgis']['data_store']['types']
  run_as_user node['arcgis']['run_as_user']
  server_url 'https://' + node['arcgis']['server']['domain_name'] + ':6443/arcgis'
  username node['arcgis']['server']['admin_username']
  password node['arcgis']['server']['admin_password']
  retries 5
  retry_delay 60
  action :configure
end

arcgis_enterprise_datastore 'Change ArcGIS DataStore backup location' do
  install_dir node['arcgis']['data_store']['install_dir']
  backup_dir node['arcgis']['data_store']['backup_dir']
  run_as_user node['arcgis']['run_as_user']
  only_if { node['arcgis']['data_store']['types'].include? 'relational' }
  action :change_backup_location
end
