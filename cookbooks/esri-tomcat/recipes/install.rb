#
# Cookbook Name:: esri-tomcat
# Recipe:: install
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'java'

instance_name = node['tomcat']['instance_name']

tomcat_install instance_name do
  version node['tomcat']['version']
  install_path node['tomcat']['install_path']
  tomcat_user node['tomcat']['user']
  tomcat_group node['tomcat']['group']
  not_if { ::File.exist?(::File.join(node['tomcat']['install_path'], 'LICENSE')) }
end

directory node['tomcat']['install_path'] do
  mode '0755'
end

directory '/home/' + node['tomcat']['user'] do
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode '0700'
  not_if { ::Dir.exist?('/home/' + node['tomcat']['user']) }
end

tomcat_service instance_name do
  action [:start, :enable]
  tomcat_user node['tomcat']['user']
  tomcat_group node['tomcat']['group']
  retries 5
  retry_delay 60
end
