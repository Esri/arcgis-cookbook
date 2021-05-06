#
# Cookbook Name:: esri-tomcat
# Recipe:: iptables
#
# Copyright 2020 Esri
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

iptables_packages 'install iptables'

# Add iptables rules to forward ports 80 to 8080 and 443 to 8443.
execute "iptables -A PREROUTING -t nat -i #{node['network']['default_interface']} -p tcp --dport 80 -j REDIRECT --to-port 8080"
execute "iptables -A PREROUTING -t nat -i #{node['network']['default_interface']} -p tcp --dport 443 -j REDIRECT --to-port 8443"
execute "iptables -A OUTPUT -t nat -o lo -p tcp --dport 80 -j REDIRECT --to-port 8080"
execute "iptables -A OUTPUT -t nat -o lo -p tcp --dport 443 -j REDIRECT --to-port 8443"

# Save the iptables rules
case node['platform']
when 'ubuntu', 'debian'
  execute 'iptables-save > /etc/iptables/rules.v4'
when 'rhel', 'redhat', 'centos'
  execute 'iptables-save > /etc/sysconfig/iptables'
end
