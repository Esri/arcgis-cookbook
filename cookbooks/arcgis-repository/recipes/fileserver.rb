#
# Cookbook Name:: arcgis-repository
# Recipe:: fileserver
#
# Copyright 2022 Esri
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

include_recipe 'nfs::server' if node['arcgis']['repository']['shared'] && node['platform'] != 'windows'

path = node['arcgis']['repository']['local_archives']

# Create archives directory
directory path do
  mode '0755' if node['platform'] != 'windows'
  recursive true
  action :create
end

# Share the directory
if node['platform'] == 'windows'
  powershell_script "Share #{path}" do
    code <<-EOH
      $sharename = Split-Path #{path} -Leaf
      net share "$sharename=#{path}"
    EOH
    guard_interpreter :powershell_script
    not_if "[bool](Get-WmiObject -Class Win32_Share -Filter \"Path='#{path}'\".Replace('\\', '\\\\'))"
    only_if { node['arcgis']['repository']['shared'] }
  end
else
  nfs_export path do
    network '*'
    writeable false
    sync true
    options ['insecure', 'no_subtree_check', 'nohide']
    only_if { node['arcgis']['repository']['shared'] }
  end
end
