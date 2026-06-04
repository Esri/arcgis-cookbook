#
# Cookbook Name:: arcgis-notebooks
# Resource:: iptables
#
# Copyright 2025 Esri
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

unified_mode true

actions :install

def initialize(*args)
  super
  @action = :install
end

use_inline_resources if defined?(use_inline_resources)

action :install do
  case node['platform_family']
  when 'rhel', 'amazon'
    # Disable firewalld and enable nftables with iptables compatibility.
    package 'iptables-services' do
      action :install 
    end

    service 'firewalld' do
      action :disable
    end

    service 'nftables' do
      action :disable
    end

    service 'iptables' do
      action :enable
    end
  when 'debian'
    package 'iptables-persistent' do
      action :install
    end
  else
    Chef::Log.warn("Cannot setup the Docker repo for platform #{node['platform']}. Skipping.")
  end
end