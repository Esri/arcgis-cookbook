#
# Cookbook Name:: arcgis-enterprise
# Provider:: server
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
require 'fileutils'
require 'json'

if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  require 'win32/service'
end

use_inline_resources

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
    repo = ::File.join(@new_resource.setups_repo, node['arcgis']['version'])
    FileUtils.mkdir_p(repo) unless ::File.directory?(repo)
    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600, :cwd => repo })
    cmd.run_command
    cmd.error!

    FileUtils.chown_R @new_resource.run_as_user, nil, repo
  end

  new_resource.updated_by_last_action(true)
end

action :install do
  cmd = 'msiexec'
  args = "/i \"#{@new_resource.setup}\" /qn IACCEPTMSODBCSQLLICENSETERMS=YES ADDLOCAL=ALL /norestart"

  # MSIEXEC will return exit code 3010 ('restart requested'), so we have to handle this exit code not equal to the default of 0 here
  cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :returns => [0, 3010], :timeout => 7200 })
  cmd.run_command
  cmd.error!

  # Wait for Server installation to finish
  sleep(10)

  new_resource.updated_by_last_action(true)
end