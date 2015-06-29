#
# Cookbook Name:: arcgis
# Provider:: desktop
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

action :install do
  cmd = @new_resource.setup
  if @new_resource.seat_preference == 'Fixed'
    args = "/qb ADDLOCAL=\"#{@new_resource.install_features}\" INSTALLDIR=\"#{@new_resource.install_dir}\" INSTALLDIR1=\"#{@new_resource.python_dir}\" DESKTOP_CONFIG=\"#{@new_resource.desktop_config}\" RENEWAL_CHECK=\"#{@new_resource.renewal_check}\" MODIFYFLEXDACL=\"#{@new_resource.modifyflexdacl}\""
  else
    args = "/qb ADDLOCAL=\"#{@new_resource.install_features}\" INSTALLDIR=\"#{@new_resource.install_dir}\" INSTALLDIR1=\"#{@new_resource.python_dir}\" ESRI_LICENSE_HOST=\"#{@new_resource.esri_license_host}\" SOFTWARE_CLASS=\"#{@new_resource.software_class}\" SEAT_PREFERENCE=\"#{@new_resource.seat_preference}\" DESKTOP_CONFIG=\"#{@new_resource.desktop_config}\" RENEWAL_CHECK=\"#{@new_resource.renewal_check}\" MODIFYFLEXDACL=\"#{@new_resource.modifyflexdacl}\""
  end

  install_dir = @new_resource.install_dir
  install_dir2 = install_dir.gsub(/\\/,'/')

  execute "Install ArcGIS for Desktop" do
    command "\"#{cmd}\" #{args}"
    only_if {::Dir.glob("#{install_dir2}/Desktop*").empty?}
  end
end

action :authorize do
  if @new_resource.seat_preference == 'Fixed'
    cmd = node['desktop']['authorization_tool']
    args = "/S /VER \"#{@new_resource.authorization_file_version}\" /LIF \"#{@new_resource.authorization_file}\""
  end
  new_resource.updated_by_last_action(true)
end
