#
# Cookbook Name:: arcgis-notebooks
# Recipe:: iptables
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

iptables_packages 'install iptables' do
  only_if { node['arcgis']['cloud']['provider'] == 'ec2' }
end

# Reject Docker containers access to EC2 instance metadata IP address.
execute	'iptables --insert DOCKER-ISOLATION-STAGE-1 --destination 169.254.169.254 --jump REJECT --verbose' do
  only_if { node['arcgis']['cloud']['provider'] == 'ec2' }
end

# Save the iptables rules
case node['platform']
when 'ubuntu', 'debian'
  execute 'iptables-save > /etc/iptables/rules.v4' do
    only_if { node['arcgis']['cloud']['provider'] == 'ec2' }
  end
when 'rhel', 'redhat', 'centos', 'oracle'
  execute 'iptables-save > /etc/sysconfig/iptables' do
    only_if { node['arcgis']['cloud']['provider'] == 'ec2' }
  end
end
