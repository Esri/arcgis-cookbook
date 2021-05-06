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

arcgis_enterprise_portal 'Start Portal for ArcGIS after install' do
  tomcat_java_opts node['arcgis']['portal']['tomcat_java_opts']
  action :start
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
arcgis_enterprise_portal 'Configure hostidentifier.properties' do
  action :configure_hostidentifiers_properties
end

arcgis_enterprise_portal 'Stop Portal for ArcGIS' do
  action :nothing
end

arcgis_enterprise_portal 'Start Portal for ArcGIS' do
  action :start
end

# Authorize portal on the machine or validate the license file if
# user type licensing is used
arcgis_enterprise_portal 'Authorize Portal for ArcGIS' do
  authorization_file node['arcgis']['portal']['authorization_file']
  authorization_file_version node['arcgis']['portal']['authorization_file_version']
  user_license_type_id node['arcgis']['portal']['user_license_type_id']
  portal_url node['arcgis']['portal']['url']
  username node['arcgis']['portal']['admin_username']
  password node['arcgis']['portal']['admin_password']
  action :authorize
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

arcgis_enterprise_portal 'Configure HTTPS' do
  portal_url node['arcgis']['portal']['url']
  username node['arcgis']['portal']['admin_username']
  password node['arcgis']['portal']['admin_password']
  keystore_file node['arcgis']['portal']['keystore_file']
  keystore_password node['arcgis']['portal']['keystore_password']
  cert_alias node['arcgis']['portal']['cert_alias']
  root_cert node['arcgis']['portal']['root_cert']
  root_cert_alias node['arcgis']['portal']['root_cert_alias']
  not_if { node['arcgis']['portal']['keystore_file'].empty? }
  retries 5
  retry_delay 30
  action :configure_https
end
