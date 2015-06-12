#
# Cookbook Name:: arcgis
# Recipe:: datastore
#
# Copyright 2014, Environmental Systems Research Institute
#
# All rights reserved
#

arcgis_datastore "Setup ArcGIS DataStore" do
  setup node['data_store']['setup']
  install_dir node['data_store']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  action :install
end

directory node['data_store']['data_dir'] do
  owner node['arcgis']['run_as_user']
  mode '0755'
  recursive true
  action :create
end

arcgis_datastore "Configure ArcGIS DataStore" do
  install_dir node['data_store']['install_dir']
  data_dir node['data_store']['data_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  server_url "https://" + node['server']['domain_name'] + ":6443/arcgis"
  username node['server']['admin_username']
  password node['server']['admin_password']
  action :configure
end