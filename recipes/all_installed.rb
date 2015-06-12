#
# Cookbook Name:: arcgis
# Recipe:: all_installed
#
# Copyright 2014, Environmental Systems Research Institute
#
#

arcgis_server "Setup ArcGIS for Server" do
  setup node['server']['setup']
  install_dir node['server']['install_dir']
  python_dir node['python']['install_dir']
  action :install
end

arcgis_datastore "Setup ArcGIS DataStore" do
  setup node['data_store']['setup']
  install_dir node['data_store']['install_dir']
  action :install
end

arcgis_portal "Setup Portal for ArcGIS" do
  install_dir node['portal']['install_dir']
  setup node['portal']['setup']
  content_dir node['portal']['content_dir']
  action :install
end

arcgis_webadaptor "Setup Web Adaptor for Server" do
  install_dir node['web_adaptor']['install_dir']
  setup node['web_adaptor']['setup']
  instance_name node['server']['wa_name']
  action :install
end

arcgis_webadaptor "Setup Web Adaptor for Portal" do
  install_dir node['web_adaptor']['install_dir']
  setup node['web_adaptor']['setup']
  instance_name node['portal']['wa_name']
  action :install
end
