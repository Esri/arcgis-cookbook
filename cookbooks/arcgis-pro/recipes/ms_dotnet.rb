#
# Cookbook Name:: arcgis-pro
# Recipe:: ms_dotnet
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

directory ::File.expand_path("..", node['ms_dotnet']['setup']) do
  recursive true
  not_if { ::File.exist?(node['ms_dotnet']['setup']) }
  action :create
end

remote_file 'Download Microsoft .NET Framework' do
  path node['ms_dotnet']['setup']
  source node['ms_dotnet']['url']
  not_if { ::File.exist?(node['ms_dotnet']['setup']) }
end

windows_package 'Install Microsoft .NET Framework' do
  source node['ms_dotnet']['setup']
  installer_type :custom
  options '/q /norestart'
  returns [0, 3010]
end
