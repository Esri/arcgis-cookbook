#
# Cookbook Name:: arcgis-enterprise
# Recipe:: fileserver
#
# Copyright 2015-2020 Esri
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

# Create file server directories

node['arcgis']['fileserver']['directories'].each do |dir|
  directory dir do
    owner node['arcgis']['run_as_user']
    mode '0700' if node['platform'] != 'windows'
    recursive true
    action :create
  end
end

# Share the directories

node['arcgis']['fileserver']['shares'].each do |path|
  if node['platform'] == 'windows'
    powershell_script "Share #{path}" do
      code <<-EOH
        $sharename = Split-Path #{path} -Leaf
        $user = '#{node['arcgis']['run_as_user']}'
        net share "$sharename=#{path}" "/Grant:$user,FULL"
      EOH
      guard_interpreter :powershell_script
      not_if "[bool](Get-WmiObject -Class Win32_Share -Filter \"Path='#{path}'\".Replace('\\', '\\\\'))"
    end
  else
    nfs_export path do
      network '*'
      writeable true
      sync true
      options ['insecure', 'no_subtree_check', 'nohide']
    end
  end
end
