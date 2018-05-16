#
# Cookbook Name:: arcgis-desktop
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

use_inline_resources if defined?(use_inline_resources)

action :system do
  if node['platform'] == 'windows'
    # TODO: Ensure Desktop system requirements 
  end
  
  new_resource.updated_by_last_action(true)
end

action :install do
  cmd = @new_resource.setup
  if @new_resource.seat_preference == 'Fixed'
    args = "/qb ADDLOCAL=\"#{@new_resource.install_features}\" INSTALLDIR=\"#{@new_resource.install_dir}\" INSTALLDIR1=\"#{@new_resource.python_dir}\" DESKTOP_CONFIG=\"#{@new_resource.desktop_config}\" MODIFYFLEXDACL=\"#{@new_resource.modifyflexdacl}\""
  else
    args = "/qb ADDLOCAL=\"#{@new_resource.install_features}\" INSTALLDIR=\"#{@new_resource.install_dir}\" INSTALLDIR1=\"#{@new_resource.python_dir}\" ESRI_LICENSE_HOST=\"#{@new_resource.esri_license_host}\" SOFTWARE_CLASS=\"#{@new_resource.software_class}\" SEAT_PREFERENCE=\"#{@new_resource.seat_preference}\" DESKTOP_CONFIG=\"#{@new_resource.desktop_config}\" MODIFYFLEXDACL=\"#{@new_resource.modifyflexdacl}\""
  end

  cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600 })
  cmd.run_command
  cmd.error!

  new_resource.updated_by_last_action(true)
end

action :uninstall do
  if node['platform'] == 'windows'
    cmd = 'msiexec'
    args = "/qb /x #{@new_resource.product_code}"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600 })
    cmd.run_command
    cmd.error!

    new_resource.updated_by_last_action(true)
  end
end

action :authorize do
  if @new_resource.seat_preference == 'Fixed'
    cmd = node['arcgis']['desktop']['authorization_tool']
    args = "/S /VER \"#{@new_resource.authorization_file_version}\" /LIF \"#{@new_resource.authorization_file}\""

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 600 })
    cmd.run_command
    cmd.error!

    new_resource.updated_by_last_action(true)
  end
end
