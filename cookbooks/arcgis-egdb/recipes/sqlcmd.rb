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
  windows_package 'SQL ODBC Driver 13.1' do
    source 'https://download.microsoft.com/download/D/5/E/D5EEF288-A277-45C8-855B-8E2CB7E25B96/x64/msodbcsql.msi'
    options 'IACCEPTMSODBCSQLLICENSETERMS=YES'
  end

  windows_package 'SQL ODBC Driver 17' do
    source 'https://download.microsoft.com/download/E/6/B/E6BFDC7A-5BCD-4C51-9912-635646DA801E/en-US/msodbcsql_17.2.0.1_x64.msi'
    options 'IACCEPTMSODBCSQLLICENSETERMS=YES'
  end

  remote_file 'c:/temp/MsSqlCmdLnUtils.msi' do
    source 'https://go.microsoft.com/fwlink/?linkid=2043518'
  end

  windows_package 'MsSqlCmdLnUtils' do
    source 'C:\temp\MsSqlCmdLnUtils.msi'
    options 'IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES'
  end
end