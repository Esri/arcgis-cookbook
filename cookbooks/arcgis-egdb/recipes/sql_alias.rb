#
# Cookbook Name:: arcgis-egdb
# Recipe:: sql_alias
#
# Copyright 2019 Esri
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

registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\MSSQLServer\Client\ConnectTo' do
  recursive true
end

registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo' do 
  recursive true
end

directory node['arcgis']['misc']['scripts_dir'] do
  recursive true
  action :create
end

template ::File.join(node['arcgis']['misc']['scripts_dir'], 'Create-SQLAliases.ps1') do
  source 'Create-SQLAliases.ps1.erb'
  cookbook 'arcgis-egdb'
  only_if { node['arcgis']['egdb']['engine'] == 'sqlserver-se' }
end

execute 'Create SQL Aliases' do
  command ['PowerShell.exe',
           '-file',
           "\"#{::File.join(node['arcgis']['misc']['scripts_dir'],
                            "Create-SQLAliases.ps1")}\"",
           '-server',
           node['arcgis']['egdb']['endpoint']].join(' ')
  only_if { node['arcgis']['egdb']['engine'] == 'sqlserver-se' &&
           !node['arcgis']['egdb']['endpoint'].nil? &&
           !node['arcgis']['egdb']['endpoint'].empty? }
end
