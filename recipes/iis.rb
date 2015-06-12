#
# Cookbook Name:: arcgis
# Recipe:: iis
#
# Copyright 2014, Environmental Systems Research Institute
#
#

arcgis_iis "Enable IIS Features" do
  action :enable
end

arcgis_iis "Configure HTTPS Binding" do
  keystore_file node['iis']['keystore_file']
  keystore_password node['iis']['keystore_password']
  action :configure_https
end

arcgis_iis "Start IIS" do
  action :start
end
