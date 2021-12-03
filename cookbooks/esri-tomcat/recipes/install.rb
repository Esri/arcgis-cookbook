#
# Cookbook Name:: esri-tomcat
# Recipe:: install
#
# Copyright 2021 Esri
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

instance_name = node['tomcat']['instance_name']

tomcat_install instance_name do
  version node['tomcat']['version']
  install_path node['tomcat']['install_path']
  tarball_path node['tomcat']['tarball_path']
  verify_checksum node['tomcat']['verify_checksum']
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
  action [:enable, :restart]
  tomcat_user node['tomcat']['user']
  tomcat_group node['tomcat']['group']
  retries 5
  retry_delay 60
end
