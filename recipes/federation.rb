#
# Cookbook Name:: arcgis
# Recipe:: webadaptor
#
# Copyright 2014, Environmental Systems Research Institute, Inc.
#
# All rights reserved 

arcgis_portal "Register Server" do
  portal_url node['portal']['url']
  username node['portal']['admin_username']
  password node['portal']['admin_password']
  server_url node['server']['url']
  is_hosted true
  action :register_server
end

arcgis_server "Federate Server" do
  portal_url node['portal']['url']
  portal_username node['portal']['admin_username']
  portal_password node['portal']['admin_password']
  server_url node['server']['url']
  server_id node['server']['server_id']
  secret_key node['server']['secret_key']
  username node['server']['admin_username']
  password node['server']['admin_password']
  action :federate
end