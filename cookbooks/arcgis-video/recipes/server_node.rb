#
# Cookbook Name:: arcgis-video
# Recipe:: server_node
#
# Copyright 2025-2026 Esri
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

include_recipe 'arcgis-video::install_server'

arcgis_video_server 'Authorize ArcGIS Video Server' do
  authorization_file node['arcgis']['video_server']['authorization_file']
  authorization_file_version node['arcgis']['video_server']['authorization_file_version']
  authorization_options node['arcgis']['video_server']['authorization_options']
  retries 2
  retry_delay 30
  notifies :stop, 'arcgis_video_server[Stop ArcGIS Video Server]', :immediately
  action :authorize
end

# Set hostname in hostname.properties file
template ::File.join(node['arcgis']['video_server']['install_dir'],
                     node['arcgis']['video_server']['install_subdir'],
                     'framework', 'etc', 'hostname.properties') do
  source 'hostname.properties.erb'
  owner node['arcgis']['run_as_user']
  group node['arcgis']['run_as_group']
  variables ( {:hostname => node['arcgis']['video_server']['hostname']} )
  notifies :stop, 'arcgis_video_server[Stop ArcGIS Video Server]', :immediately
  notifies :delete, 'directory[Delete ArcGIS Video Server certificates directory]', :immediately
  not_if { node['arcgis']['video_server']['hostname'].empty? }
end

# Restart ArcGIS Video Server
arcgis_video_server 'Stop ArcGIS Video Server' do
  install_dir node['arcgis']['video_server']['install_dir']
  action :nothing
end

# Delete SSL certificates issued to the old hostname to make ArcGIS Video Server
# recreate the certificates for hostname set in hostname.properties file.
directory 'Delete ArcGIS Video Server certificates directory' do
  path ::File.join(node['arcgis']['video_server']['install_dir'],
                   node['arcgis']['video_server']['install_subdir'],
                   'framework', 'etc', 'certificates')
  # Do not delete certificates directory if ArcGIS Video Server site already exists.
  not_if { ::File.exist?(::File.join(node['arcgis']['video_server']['install_dir'],
                                     node['arcgis']['video_server']['install_subdir'],
                                     'framework', 'etc', 'config-store-connection.json')) }
  recursive true
  action :nothing
end

arcgis_video_server 'Start ArcGIS Video Server' do
  install_dir node['arcgis']['video_server']['install_dir']
  action :start
end

# Create local server logs directory
directory node['arcgis']['video_server']['log_dir'] do
  owner node['arcgis']['run_as_user']
  if node['platform'] != 'windows'
    mode '0700'
  end
  recursive true
  not_if { node['arcgis']['video_server']['log_dir'].start_with?('\\\\') ||
           node['arcgis']['video_server']['log_dir'].start_with?('/net/') }
  action :create
end

arcgis_video_server 'Join ArcGIS Video Server site' do
  install_dir node['arcgis']['video_server']['install_dir']
  server_url node['arcgis']['video_server']['url']
  username node['arcgis']['video_server']['admin_username']
  password node['arcgis']['video_server']['admin_password']
  primary_server_url node['arcgis']['video_server']['primary_server_url']
  retries 5
  retry_delay 30
  action :join_site
end

arcgis_video_server 'Configure HTTPS' do
  server_url node['arcgis']['video_server']['url']
  username node['arcgis']['video_server']['admin_username']
  password node['arcgis']['video_server']['admin_password']
  keystore_file node['arcgis']['video_server']['keystore_file']
  keystore_password node['arcgis']['video_server']['keystore_password']
  cert_alias node['arcgis']['video_server']['cert_alias']
  root_cert node['arcgis']['video_server']['root_cert']
  root_cert_alias node['arcgis']['video_server']['root_cert_alias']
  import_certificate_chain node['arcgis']['video_server']['import_certificate_chain']
  retries 5
  retry_delay 30
  not_if { node['arcgis']['video_server']['keystore_file'].empty? &&
           node['arcgis']['video_server']['root_cert'].empty? }
  action :configure_https
end
