#
# Cookbook Name:: esri-tomcat
# Attributes:: default
#
# Copyright 2024 Esri
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

default['tomcat']['version'] = '9.0.83'

default['tomcat']['instance_name'] = 'arcgis'
default['tomcat']['install_path'] = '/opt/tomcat_' + node['tomcat']['instance_name'] + '_' + node['tomcat']['version']
default['tomcat']['tarball_base_uri'] = 'https://archive.apache.org/dist/tomcat/'
default['tomcat']['checksum_base_uri'] = 'https://archive.apache.org/dist/tomcat/'
default['tomcat']['tarball_path'] = "#{Chef::Config['file_cache_path']}/apache-tomcat-#{node['tomcat']['version']}.tar.gz"

default['tomcat']['create_symlink'] = true
default['tomcat']['symlink_path'] = "/opt/tomcat_#{node['tomcat']['instance_name']}"

default['tomcat']['tomcat_user_shell'] = '/bin/false'
default['tomcat']['create_user'] = true
default['tomcat']['create_group'] = true
default['tomcat']['user'] = 'tomcat_' + node['tomcat']['instance_name']
default['tomcat']['group'] = 'tomcat_' + node['tomcat']['instance_name']

default['tomcat']['ssl_enabled_protocols'] = 'TLSv1.3,TLSv1.2'
default['tomcat']['keystore_file']  = ''
if ENV['TOMCAT_KEYSTORE_PASSWORD'].nil?
  default['tomcat']['keystore_password']  = nil
else
  default['tomcat']['keystore_password']  = ENV['TOMCAT_KEYSTORE_PASSWORD']
end
default['tomcat']['keystore_type']  = 'PKCS12'
default['tomcat']['domain_name']  = node['fqdn']
default['tomcat']['verify_checksum'] = true
default['tomcat']['forward_ports'] = true
default['tomcat']['firewalld']['init_cmd'] = 'firewall-cmd --zone=public --permanent --add-port=0-65535/tcp'

default['java']['version'] = '11.0.21+9'
default['java']['tarball_uri'] = 'https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.21%2B9/OpenJDK11U-jdk_x64_linux_hotspot_11.0.21_9.tar.gz'
default['java']['tarball_path'] = "#{Chef::Config['file_cache_path']}/OpenJDK11U-jdk_x64_linux_hotspot_11.0.21_9.tar.gz"
default['java']['install_path'] = '/opt'
