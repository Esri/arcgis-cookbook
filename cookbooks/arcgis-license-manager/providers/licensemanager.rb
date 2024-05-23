#
# Cookbook Name:: arcgis-license-manager
# Provider:: licensemanager
#
# Copyright 2024 Esri
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
    # TODO: Ensure License Manager system requirements on Windows
  else
    arcgis_license_manager_user @new_resource.recipe_name + ':create-licensemanager-account'

    node['arcgis']['licensemanager']['packages'].each do |pckg|
      package pckg do
        retries 5
        retry_delay 60
      end
    end
  end

  new_resource.updated_by_last_action(true)
end

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
    repo = ::File.join(@new_resource.setups_repo, node['arcgis']['licensemanager']['version'])
    FileUtils.mkdir_p(repo) unless ::File.directory?(repo)
    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600, :cwd => repo })
    cmd.run_command
    cmd.error!

    FileUtils.chown_R @new_resource.run_as_user, nil, repo
  end

  new_resource.updated_by_last_action(true)
end

action :install do
  unless ::File.exists?(@new_resource.setup)
    raise "File '#{@new_resource.setup}' not found."
  end

  if node['platform'] == 'windows'
    cmd = @new_resource.setup
    args = "/qn ACCEPTEULA=Yes ADDLOCAL=ALL INSTALLDIR=\"#{@new_resource.install_dir}\""

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}")
    cmd.run_command
    cmd.error!
  else
    cmd = @new_resource.setup
    args  = "-m silent -l yes -d \"#{@new_resource.install_dir}\""
    run_as_user = @new_resource.run_as_user

    subdir = @new_resource.install_dir
    node['arcgis']['licensemanager']['install_subdir'].split("/").each do |path|
      subdir = ::File.join(subdir, path)
      FileUtils.mkdir_p(subdir) unless ::File.directory?(subdir)
      FileUtils.chmod 0700, subdir
      FileUtils.chown run_as_user, 'root', subdir
    end

    %w{macrovision macrovision/storage}.each do |dir|
      subdir = "/usr/local/share/#{dir}"
      unless ::File.directory?(subdir)
        FileUtils.mkdir(subdir)
      end
      FileUtils.chmod(0755, subdir)
      FileUtils.chown(run_as_user, 'root', subdir)
    end

    cmd = Mixlib::ShellOut.new("su - #{run_as_user} -c \"#{cmd} #{args}\"")
    cmd.run_command
    cmd.error!
  end

  new_resource.updated_by_last_action(true)
end

action :uninstall do
  if node['platform'] == 'windows'
    cmd = 'msiexec'
    args = "/qn /x #{@new_resource.product_code}"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}")
    cmd.run_command
    cmd.error!
  else
    install_subdir = ::File.join(@new_resource.install_dir, node['arcgis']['licensemanager']['install_subdir'])
    cmd = ::File.join(install_subdir, 'uninstallLicenseManager')
    args = "-s"

    cmd = Mixlib::ShellOut.new("su - #{node['arcgis']['run_as_user']} -c \"#{cmd} #{args}\"")
    cmd.run_command
    cmd.error!
  end

  new_resource.updated_by_last_action(true)
end
