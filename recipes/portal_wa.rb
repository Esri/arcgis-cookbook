#
# Cookbook Name:: arcgis
# Recipe:: portal_wa
#
# Copyright 2014, Environmental Systems Research Institute
#
# All rights reserved
#

arcgis_webadaptor "Setup Web Adaptor for Portal" do
  install_dir node['web_adaptor']['install_dir']
  setup node['web_adaptor']['setup']
  instance_name node['portal']['wa_name']
  action :install
end

arcgis_webadaptor "Configure Web Adaptor with Portal" do
  portal_url node['portal']['url']
  portal_local_url "https://" + node['portal']['domain_name'] + ":7443"
  install_dir node['web_adaptor']['install_dir']
  instance_name node['portal']['wa_name']
  username node['portal']['admin_username']
  password node['portal']['admin_password']
  action :configure_with_portal
end
