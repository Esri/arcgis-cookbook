#
# Cookbook Name:: arcgis-enterprise
# Recipe:: sql_alias
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

execute 'Create SQL Aliases' do
  command ['PowerShell.exe',
           '-file',
           "\"#{::File.join(node['arcgis']['server']['install_dir'],
                            "framework", "etc", "Create-SQLAliases.ps1")}\"",
           '-server',
           node['arcgis']['rds']['endpoint']].join(' ')
  only_if { node['arcgis']['rds']['engine'] == 'sqlserver-se' &&
           !node['arcgis']['rds']['endpoint'].nil? &&
           !node['arcgis']['rds']['endpoint'].empty? }
end
