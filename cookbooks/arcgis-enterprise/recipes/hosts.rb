#
# Cookbook Name:: arcgis-enterprise
# Recipe:: hosts
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

unless node['arcgis']['hosts'].nil?
  node['arcgis']['hosts'].each do |host, ip|
    ip = node['ipaddress'] if ip.empty?
    hostsfile_entry "Map #{host} to #{ip}" do
      hostname host
      ip_address ip
      unique true
      action :create
    end
  end
end
