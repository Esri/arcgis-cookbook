#
# Cookbook Name:: esri-tomcat
# Recipe:: firewalld
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

# Install firewalld if it's not already installed
package 'firewalld' do
  action :install
end

service 'enable firewalld' do
  service_name 'firewalld'
  supports :status => true, :restart => true, :reload => true
  action :enable
end

service 'start firewalld' do
  service_name 'firewalld'
  supports :status => true, :restart => true, :reload => true
  notifies :run, 'execute[init firewalld]', :immediately
  action :start
end

execute 'init firewalld' do
  command node['tomcat']['firewalld']['init_cmd']
  action :nothing
end

# Enable masquerading for external zone
execute 'firewall-cmd --add-masquerade'

# Add firewalld services to forward ports 80 to 8080 and 443 to 8443.
execute 'firewall-cmd --permanent --add-forward-port=port=80:proto=tcp:toport=8080'
execute 'firewall-cmd --permanent --add-forward-port=port=443:proto=tcp:toport=8443'
execute 'firewall-cmd --permanent --direct --add-rule ipv4 nat OUTPUT 0 -p tcp -o lo --dport 80 -j REDIRECT --to-ports 8080'
execute 'firewall-cmd --permanent --direct --add-rule ipv4 nat OUTPUT 0 -p tcp -o lo --dport 443 -j REDIRECT --to-ports 8443'

execute 'firewall-cmd --reload'
