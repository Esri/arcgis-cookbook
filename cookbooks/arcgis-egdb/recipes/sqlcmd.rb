#
# Cookbook Name:: arcgis-egdb
# Recipe:: sqlcmd
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

case node['platform']
when 'windows'
  # Install Microsoft Visual C++ 2017 Redistributable (x64)
  
  directory ::File.dirname(node['arcgis']['egdb']['vc_redist_path']) do
    recursive true
    action :create
  end

  remote_file node['arcgis']['egdb']['vc_redist_path'] do
    source node['arcgis']['egdb']['vc_redist_url']
    not_if { ::File.exist?(node['arcgis']['egdb']['vc_redist_path']) }
  end

  windows_package 'Microsoft Visual C++ 2017 Redistributable (x64)' do
    source node['arcgis']['egdb']['vc_redist_path']
    installer_type :custom
    options '/Q'
    returns [0, 3010, 1638]
  end

  # Install MS SQL ODBC Driver 13

  directory ::File.dirname(node['arcgis']['egdb']['msodbcsql13_msi_path']) do
    recursive true
    action :create
  end

  remote_file node['arcgis']['egdb']['msodbcsql13_msi_path'] do
    source node['arcgis']['egdb']['msodbcsql13_msi_url']
    not_if { ::File.exist?(node['arcgis']['egdb']['msodbcsql13_msi_path']) }
  end

  windows_package 'SQL ODBC Driver 13' do
    source node['arcgis']['egdb']['msodbcsql13_msi_path']
    options 'IACCEPTMSODBCSQLLICENSETERMS=YES'
    returns [0, 3010, 1638]
  end

  # Install MS SQL ODBC Driver 17

  directory ::File.dirname(node['arcgis']['egdb']['msodbcsql17_msi_path']) do
    recursive true
    action :create
  end

  remote_file node['arcgis']['egdb']['msodbcsql17_msi_path'] do
    source node['arcgis']['egdb']['msodbcsql17_msi_url']
    not_if { ::File.exist?(node['arcgis']['egdb']['msodbcsql17_msi_path']) }
  end

  windows_package 'SQL ODBC Driver 17' do
    source node['arcgis']['egdb']['msodbcsql17_msi_path']
    options 'IACCEPTMSODBCSQLLICENSETERMS=YES'
    returns [0, 3010, 1638]
  end

  # Install MS SQL Command Line Utilities

  directory ::File.dirname(node['arcgis']['egdb']['mssqlcmdlnutils_msi_path']) do
    recursive true
    action :create
  end

  remote_file node['arcgis']['egdb']['mssqlcmdlnutils_msi_path'] do
    source node['arcgis']['egdb']['mssqlcmdlnutils_msi_url']
    not_if { ::File.exist?(node['arcgis']['egdb']['mssqlcmdlnutils_msi_path']) }
  end

  windows_package 'MS SQL Command Line Utils' do
    source node['arcgis']['egdb']['mssqlcmdlnutils_msi_path']
    options 'IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES'
  end
end
