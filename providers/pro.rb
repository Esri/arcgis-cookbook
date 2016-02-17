#
# Cookbook Name:: arcgis
# Provider:: pro
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

action :system do
  if node['platform'] == 'windows'
    # TODO: Ensure Desktop system requirements
  end
  new_resource.updated_by_last_action(true)
end

action :install do
  cmd = node[:arcgis][:pro][:setup]
  args = "ALLUSERS=#{node[:arcgis][:pro][:allusers]} BLOCKADDINS=#{node[:arcgis][:pro][:blockaddins]} INSTALLDIR=\"#{node[:arcgis][:pro][:install_dir]}\" /qn"

  execute 'Install ArcGIS Pro' do
    command "msiexec.exe /i \"#{cmd}\" #{args}"
    only_if { ::Dir.glob("#{node[:arcgis][:pro][:install_dir]}/ArcGISPro*").empty? }
  end
  new_resource.updated_by_last_action(true)
end
