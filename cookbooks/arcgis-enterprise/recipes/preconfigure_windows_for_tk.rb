#
# Cookbook Name:: arcgis-enterprise
# Recipe:: preconfigure_windows_for_tk.rb
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

directory node['temp_dir'] do
  action :create
end

directory node['setup_dir'] do
  action :create
end

powershell_script 'Set PowerShell Execution Policy to RemoteSigned x64' do
  guard_interpreter :powershell_script
  code <<-EOH
    Set-ExecutionPolicy RemoteSigned -Force
  EOH
  not_if "(Get-ExecutionPolicy -Scope LocalMachine) -eq 'RemoteSigned'"
  returns [0, 1]
end

powershell_script 'Set PowerShell Execution Policy to RemoteSigned x86' do
  guard_interpreter :powershell_script
  architecture :i386
  code <<-EOH
    Set-ExecutionPolicy RemoteSigned -Force
  EOH
  not_if "(Get-ExecutionPolicy -Scope LocalMachine) -eq 'RemoteSigned'"
  returns [0, 1]
end

powershell_script 'Make Drives Online' do
  code <<-EOH
    $makeDiskOnlineCommandC = @("select disk 0", "online disk")
    $makeDiskOnlineCommandD = @("select disk 1", "online disk")
    $removeReadOnlyProp = @("select disk 1", "attribute disk clear readonly")
    $makeDiskOnlineCommandC | DiskPart
    $makeDiskOnlineCommandD | DiskPart
    $removeReadOnlyProp | DiskPart
  EOH
end

env 'arcgis_cloud_platform' do
  value 'aws'
  action :create
end

powershell_script 'Download ArcGIS Setups' do
  code <<-EOH
    Read-S3Object -BucketName #{node['s3_bucket']} -KeyPrefix #{node['s3_setup_dir']} -folder #{node['setup_dir']}
  EOH
  retries 3
end

powershell_script 'Extract ArcGIS Setups' do
  cwd node['setup_dir']
  code <<-EOH
    & tar xvf arcgis.tar
  EOH
  retries 3
  returns [0, 1]
end

powershell_script 'Rename GeoEvent Setups Directory' do
  cwd node['setup_dir']
  code <<-EOH
    Rename-Item Windows GeoEvent
  EOH
  ignore_failure true
end
