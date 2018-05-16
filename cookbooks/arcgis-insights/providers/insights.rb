#
# Cookbook Name:: arcgis-insights
# Provider:: insights
#
# Copyright 2017 Esri
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

use_inline_resources if defined?(use_inline_resources)

action :unpack do
  if node['platform'] == 'windows'
    cmd = @new_resource.setup_archive
    args = "/s /d \"#{@new_resource.setups_repo}\""
    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600 })
    cmd.run_command
    cmd.error!
  else
    cmd = 'tar'
    args = "xzvf \"#{@new_resource.setup_archive}\""
    repo = ::File.join(@new_resource.setups_repo, node['arcgis']['insights']['version'])
    FileUtils.mkdir_p(repo) unless ::File.directory?(repo)
    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600, :cwd => repo })
    cmd.run_command
    cmd.error!

    FileUtils.chown_R @new_resource.run_as_user, nil, repo
  end

  new_resource.updated_by_last_action(true)
end

action :install do
  if node['platform'] == 'windows'
    cmd = @new_resource.setup
    args = "/qb"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600 })
    cmd.run_command
    cmd.error!
  else
    cmd = @new_resource.setup
    run_as_user = @new_resource.run_as_user

    cmd = Mixlib::ShellOut.new("su - #{run_as_user} -c \"#{cmd}\"",
                               { :timeout => 3600 })
    cmd.run_command
    cmd.error!
  end

  new_resource.updated_by_last_action(true)
end

action :uninstall do
  if node['platform'] == 'windows'
    cmd = 'msiexec'
    args = "/qb /x #{@new_resource.product_code}"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600 })
    cmd.run_command
    cmd.error!
  else
    cmd = ::File.join(node['arcgis']['server']['install_dir'],
                      node['arcgis']['server']['install_subdir'],
                      'uninstall_Insights.sh')

    if ::File.exist?(cmd) 
      args = '-s'
      cmd = Mixlib::ShellOut.new("su - #{@new_resource.run_as_user} -c \"#{cmd} #{args}\"",
                                 { :timeout => 3600 })
      cmd.run_command
      cmd.error!
    end

    cmd = ::File.join(node['arcgis']['portal']['install_dir'],
                      node['arcgis']['portal']['install_subdir'],
                      'uninstall_Insights.sh')

    if ::File.exist?(cmd)
      args = '-s'
      cmd = Mixlib::ShellOut.new("su - #{@new_resource.run_as_user} -c \"#{cmd} #{args}\"",
                                 { :timeout => 3600 })
      cmd.run_command
      cmd.error!
    end
  end

  new_resource.updated_by_last_action(true)
end

