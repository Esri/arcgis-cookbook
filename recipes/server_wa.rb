#
# Cookbook Name:: arcgis
# Recipe:: server_wa
#
# Copyright 2014, Environmental Systems Research Institute
#
#

hostsfile_entry "Map server domain name to localhost" do
  ip_address "127.0.0.1"
  hostname node['server']['domain_name']
  action :append
end

arcgis_webadaptor "Setup Web Adaptor for Server" do
  install_dir node['web_adaptor']['install_dir']
  setup node['web_adaptor']['setup']
  instance_name node['server']['wa_name']
  action :install
end

arcgis_webadaptor "Configure Web Adaptor with Server" do
  install_dir node['web_adaptor']['install_dir']
  server_url node['server']['url']
  #server_local_url node['server']['local_url']
  server_local_url "http://localhost:6080"
  username node['server']['admin_username']
  password node['server']['admin_password']
  action :configure_with_server
end
