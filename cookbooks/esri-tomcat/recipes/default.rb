#
# Cookbook Name:: esri-tomcat
# Recipe:: default
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

include_recipe 'esri-tomcat::install'
include_recipe 'esri-tomcat::configure_ssl'

if node['tomcat']['forward_ports']
  # Forward port 80 to 8080 and 443 to 8443 using firewalld or iptables.
  case node['platform']
  when 'centos', 'redhat', 'rhel', 'amazon', 'oracle', 'suse', 'rocky', 'almalinux'
    include_recipe 'esri-tomcat::firewalld'
  else
    include_recipe 'esri-tomcat::iptables'
  end
end
