#
# Cookbook Name:: arcgis
# Recipe:: server
#
# Copyright 2014, Environmental Systems Research Institute
#
#

arcgis_server "Setup ArcGIS for Server" do
  setup node['server']['setup']
  install_dir node['server']['install_dir']
  python_dir node['python']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  action :install
end

arcgis_server "Authorize ArcGIS for Server" do
  authorization_file node['server']['authorization_file']
  authorization_file_version node['server']['authorization_file_version']
  action :authorize
end

directory node['server']['directories_root'] do
  owner node['arcgis']['run_as_user']
  mode '0755'
  recursive true
  action :create
end

arcgis_server "Create ArcGIS for Server Site" do
  server_url node['server']['local_url']
  username node['server']['admin_username']
  password node['server']['admin_password']
  server_directories_root node['server']['directories_root']
  action :create_site
end

arcgis_server "Enable SSL on ArcGIS Server Site" do
  server_url node['server']['local_url']
  username node['server']['admin_username']
  password node['server']['admin_password']
  action :enable_ssl
end

arcgis_server "Register Managed Database" do
  server_url node['server']['local_url']
  username node['server']['admin_username']
  password node['server']['admin_password']
  data_item_path "/enterpriseDatabases/managedDatabase"
  connection_string node['server']['managed_database']
  is_managed true
  action :register_database
end

arcgis_server "Register Replicated Database" do
  server_url node['server']['local_url']
  username node['server']['admin_username']
  password node['server']['admin_password']
  data_item_path "/namedWorkspaces/replicatedDatabase"
  connection_string node['server']['replicated_database']
  is_managed false
  action :register_database
end
