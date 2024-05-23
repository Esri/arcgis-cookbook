#
# Cookbook Name:: arcgis-notebooks
# Resource:: data
#
# Copyright 2023 Esri
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

unified_mode true

actions :unpack, :install, :post_install

attribute :setup_archive, kind_of: String
attribute :setups_repo, kind_of: String
attribute :setup, kind_of: String
attribute :install_dir, :kind_of => String
attribute :run_as_user, :kind_of => String

def initialize(*args)
  super
  @action = :install
end

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
    repo = ::File.join(@new_resource.setups_repo, node['arcgis']['version'])
    FileUtils.mkdir_p(repo) unless ::File.directory?(repo)
    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600, :cwd => repo })
    cmd.run_command
    cmd.error!

    FileUtils.chown_R @new_resource.run_as_user, nil, repo
  end
end

action :install do
  unless ::File.exists?(@new_resource.setup)
    raise "File '#{@new_resource.setup}' not found."
  end

  if node['platform'] == 'windows'
    cmd = @new_resource.setup
    args = "/qn ACCEPTEULA=Yes"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600 })
    cmd.run_command
    cmd.error!
  else
    cmd = @new_resource.setup
    run_as_user = @new_resource.run_as_user

    if node['arcgis']['run_as_superuser']
      cmd = Mixlib::ShellOut.new("su - #{run_as_user} -c \"#{cmd}\"", { :timeout => 3600 })
    else
      cmd = Mixlib::ShellOut.new("#{cmd}", { :user => run_as_user, :timeout => 3600 })
    end

    cmd.run_command
    cmd.error!
  end
end

action :post_install do
  if node['platform'] == 'windows'
    cmd = ::File.join(@new_resource.install_dir, 'tools', 'postInstallUtility', 'PostInstallUtility.bat')
    args = "-x"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 1200 })
    cmd.run_command
    cmd.error!
  else
    install_dir = ::File.join(@new_resource.install_dir, node['arcgis']['notebook_server']['install_subdir'])
    cmd = ::File.join(install_dir, 'tools', 'postInstallUtility', 'PostInstallUtility.sh')
    args = "-x"

    cmd = Mixlib::ShellOut.new("su - #{@new_resource.run_as_user} -c \"#{cmd} #{args}\"",
          { :timeout => 1200 })
    cmd.run_command
    cmd.error!
  end
end
