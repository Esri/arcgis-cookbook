#
# Cookbook Name:: arcgis-enterprise
# Recipe:: portal_standby
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

include_recipe 'arcgis-enterprise::install_portal'

arcgis_enterprise_portal 'Authorize Portal for ArcGIS' do
  authorization_file node['arcgis']['portal']['authorization_file']
  authorization_file_version node['arcgis']['portal']['authorization_file_version']
  retries 5
  retry_delay 60
  not_if { ::File.exists?(node['arcgis']['portal']['cached_authorization_file']) &&
           FileUtils.compare_file(node['arcgis']['portal']['authorization_file'],
                                  node['arcgis']['portal']['cached_authorization_file']) }
  action :authorize
end

# Copy portal authorization file to the machine to indicate that portal is already authorized
file 'Cache portal authorization file' do
  path node['arcgis']['portal']['cached_authorization_file']
  if ::File.exists?(node['arcgis']['portal']['authorization_file'])
    content File.open(node['arcgis']['portal']['authorization_file'], 'rb') { |file| file.read }
  end
  sensitive true
  subscribes :create, 'arcgis_enterprise_portal[Authorize Portal for ArcGIS]', :immediately
  only_if { node['arcgis']['cache_authorization_files'] }
  action :nothing
end

# Set hostname in hostname.properties file.
template ::File.join(node['arcgis']['portal']['install_dir'],
                     node['arcgis']['portal']['install_subdir'],
                     'framework', 'etc', 'hostname.properties') do
  source 'hostname.properties.erb'
  variables ( {:hostname => node['arcgis']['portal']['hostname']} )
  notifies :stop, 'arcgis_enterprise_portal[Stop Portal for ArcGIS]', :immediately
  not_if { node['arcgis']['portal']['hostname'].empty? }
end

# Set hostidentifier and preferredidentifier in hostidentifier.properties file.
template ::File.join(node['arcgis']['portal']['install_dir'],
                     node['arcgis']['portal']['install_subdir'],
                     'framework', 'runtime', 'ds', 'framework', 'etc',
                     'hostidentifier.properties') do
  source 'hostidentifier.properties.erb'
  variables ( {:hostidentifier => node['arcgis']['portal']['hostidentifier'],
               :preferredidentifier => node['arcgis']['portal']['preferredidentifier']} )
end

arcgis_enterprise_portal 'Stop Portal for ArcGIS' do
  action :nothing
end

arcgis_enterprise_portal 'Start Portal for ArcGIS' do
  action :start
end

arcgis_enterprise_portal 'Join Portal Site' do
  portal_url node['arcgis']['portal']['url']
  primary_machine_url node['arcgis']['portal']['primary_machine_url']
  username node['arcgis']['portal']['admin_username']
  password node['arcgis']['portal']['admin_password']
  upgrade_backup node['arcgis']['portal']['upgrade_backup']
  upgrade_rollback node['arcgis']['portal']['upgrade_rollback']
  retries 5
  retry_delay 30
  action :join_site
end
