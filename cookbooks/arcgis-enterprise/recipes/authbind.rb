#
# Cookbook Name:: arcgis-enterprise
# Recipe:: authbind
#
# Copyright 2015 Esri
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

unless platform_family?('windows')
  tomcat_user = node['tomcat']['user'].nil? ? 'tomcat7' : node['tomcat']['user']
  port = node['tomcat']['port'].nil? ? 80 : node['tomcat']['port']
  ssl_port = node['tomcat']['ssl_port'].nil? ? 443 : node['tomcat']['ssl_port']

  user tomcat_user do
    comment 'Tomcat user account'
    manage_home true
    home '/home/' + tomcat_user
    action :create
  end

  directory '/etc/authbind/byport' do
    recursive true
    action :create
  end

  [port, ssl_port].each do |p|
    authbind_port "AuthBind Tomcat Port #{p}" do
      port p
      user tomcat_user
    end
  end
end
