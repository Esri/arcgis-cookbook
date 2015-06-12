#
# Cookbook Name:: arcgis
# Recipe:: authbind
#
# Copyright 2014, Environmental Systems Research Institute
#
# All rights reserved
#

if !platform_family?('windows')
  tomcat_user = node['tomcat']['user'].nil? ? "tomcat7" : node['tomcat']['user'] 
  port = node['tomcat']['port'].nil? ? 80 : node['tomcat']['port']
  ssl_port = node['tomcat']['ssl_port'].nil? ? 443 : node['tomcat']['ssl_port']
    
  user tomcat_user do
    comment 'Tomcat user account'
    supports :manage_home => true
    home '/home/' + tomcat_user
    action :create
  end
  
  directory "/etc/authbind/byport" do
    recursive true
    action :create
  end
  
  [port, ssl_port].each do |port|
    authbind_port "AuthBind Tomcat Port #{port}" do
      port port
      user tomcat_user
    end
  end
end