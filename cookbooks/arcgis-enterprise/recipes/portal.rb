#
# Cookbook Name:: arcgis-enterprise
# Recipe:: portal
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
  tomcat_java_opts node['arcgis']['portal']['tomcat_java_opts']
  action :nothing
end

arcgis_enterprise_portal 'Start Portal for ArcGIS' do
  tomcat_java_opts node['arcgis']['portal']['tomcat_java_opts']
  action :start
end

# Create Site
arcgis_enterprise_portal 'Create Portal Site' do
  portal_url node['arcgis']['portal']['url']
  portal_private_url node['arcgis']['portal']['private_url']
  web_context_url node['arcgis']['portal']['web_context_url']
  username node['arcgis']['portal']['admin_username']
  password node['arcgis']['portal']['admin_password']
  full_name node['arcgis']['portal']['admin_full_name']
  email node['arcgis']['portal']['admin_email']
  description node['arcgis']['portal']['admin_description']
  security_question node['arcgis']['portal']['security_question']
  security_question_answer node['arcgis']['portal']['security_question_answer']
  install_dir node['arcgis']['portal']['install_dir']
  #content_dir node['arcgis']['portal']['content_dir']
  content_store_type node['arcgis']['portal']['content_store_type']
  content_store_provider node['arcgis']['portal']['content_store_provider']
  content_store_connection_string node['arcgis']['portal']['content_store_connection_string']
  object_store node['arcgis']['portal']['object_store']
  log_level node['arcgis']['portal']['log_level']
  log_dir node['arcgis']['portal']['log_dir']
  max_log_file_age node['arcgis']['portal']['max_log_file_age']
  upgrade_backup node['arcgis']['portal']['upgrade_backup']
  upgrade_rollback node['arcgis']['portal']['upgrade_rollback']
  root_cert node['arcgis']['portal']['root_cert']
  root_cert_alias node['arcgis']['portal']['root_cert_alias']
  action :create_site
end

arcgis_enterprise_portal 'Configure HTTPS' do
  portal_url node['arcgis']['portal']['url']
  username node['arcgis']['portal']['admin_username']
  password node['arcgis']['portal']['admin_password']
  keystore_file node['arcgis']['portal']['keystore_file']
  keystore_password node['arcgis']['portal']['keystore_password']
  cert_alias node['arcgis']['portal']['cert_alias']
  not_if { node['arcgis']['portal']['keystore_file'].empty? }
  retries 5
  retry_delay 30
  action :configure_https
end

arcgis_enterprise_portal 'Configure All SSL' do
  portal_url node['arcgis']['portal']['url']
  username node['arcgis']['portal']['admin_username']
  password node['arcgis']['portal']['admin_password']
  allssl node['arcgis']['portal']['allssl']
  retries 5
  retry_delay 30
  action :set_allssl
end