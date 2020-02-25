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

action :unpack do
  cmd = @new_resource.setup_archive
  args = "/s /d \"#{@new_resource.setups_repo}\""
  cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600 })
  cmd.run_command
  cmd.error!

  new_resource.updated_by_last_action(true)
end

action :install do
  cmd = node['arcgis']['pro']['setup']

  if node['arcgis']['pro']['authorization_type'] == 'NAMED_USER'
    args = "ALLUSERS=#{node['arcgis']['pro']['allusers']} BLOCKADDINS=#{node['arcgis']['pro']['blockaddins']} INSTALLDIR=\"#{node['arcgis']['pro']['install_dir']}\" /qb"
  end

  if node['arcgis']['pro']['authorization_type'] == 'SINGLE_USE'
    args = "ALLUSERS=#{node['arcgis']['pro']['allusers']} Portal_List=#{node['arcgis']['pro']['portal_list']} AUTHORIZATION_TYPE=#{node['arcgis']['pro']['authorization_type']} SOFTWARE_CLASS=#{node['arcgis']['pro']['software_class']} BLOCKADDINS=#{node['arcgis']['pro']['blockaddins']} INSTALLDIR=\"#{node['arcgis']['pro']['install_dir']}\" /qb"
  end

  if node['arcgis']['pro']['authorization_type'] == 'CONCURRENT_USE'
    args = "ALLUSERS=#{node['arcgis']['pro']['allusers']} Portal_List=#{node['arcgis']['pro']['portal_list']} ESRI_LICENSE_HOST=#{node['arcgis']['pro']['esri_license_host']} AUTHORIZATION_TYPE=#{node['arcgis']['pro']['authorization_type']} SOFTWARE_CLASS=#{node['arcgis']['pro']['software_class']} BLOCKADDINS=#{node['arcgis']['pro']['blockaddins']} INSTALLDIR=\"#{node['arcgis']['pro']['install_dir']}\" /qb"  
  end

  cmd = Mixlib::ShellOut.new("msiexec.exe /i \"#{cmd}\" #{args}",
                             { :timeout => 3600 })
  cmd.run_command
  cmd.error!

  new_resource.updated_by_last_action(true)
end


action :patches do
	# Dir.glob() doesn't support backslashes within a path, so they will be replaces on Windows
	patch_folder = node['arcgis']['patches']['local_patch_folder'].gsub('\\','/')

	# get all patches  within the specified folder and register them
	Dir.glob("#{patch_folder}/**/*.msp").each do |patch|
	  windows_package "Install #{patch}" do
		action :install
		source patch
		installer_type :custom
		options '/qn'
	  end
	end

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

action :authorize do
  cmd = node['arcgis']['pro']['authorization_tool']
  if node['arcgis']['pro']['authorization_type'] == 'SINGLE_USE'
    args = "/LIF \"#{@new_resource.authorization_file}\" /S /VER \"#{@new_resource.authorization_file_version}\""

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 600 })
    cmd.run_command
    cmd.error!

    new_resource.updated_by_last_action(true)
  end
end

