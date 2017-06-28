#
# Cookbook Name:: arcgis-pro
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

use_inline_resources if defined?(use_inline_resources)

action :system do
  if node['platform'] == 'windows'
    # TODO: Ensure Pro system requirements
    #new_resource.updated_by_last_action(true)
  end

  new_resource.updated_by_last_action(false)
end

action :install do
  cmd = node['arcgis']['pro']['setup']
  args = "ALLUSERS=#{node['arcgis']['pro']['allusers']} BLOCKADDINS=#{node['arcgis']['pro']['blockaddins']} INSTALLDIR=\"#{node['arcgis']['pro']['install_dir']}\" /qb"

  cmd = Mixlib::ShellOut.new("msiexec.exe /i \"#{cmd}\" #{args}",
                             { :timeout => 3600 })
  cmd.run_command
  cmd.error!

  new_resource.updated_by_last_action(true)
end

action :uninstall do
  cmd = 'msiexec'
  args = "/qb /x #{@new_resource.product_code}"

  cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
                             { :timeout => 3600 })
  cmd.run_command
  cmd.error!

  new_resource.updated_by_last_action(true)
end
