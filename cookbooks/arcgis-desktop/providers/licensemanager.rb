#
# Cookbook Name:: arcgis-desktop
# Provider:: licensemanager
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
    #TODO: Ensure License Manager system requirements on Windows
  else
    arcgis_desktop_user @new_resource.recipe_name + ':create-licensemanager-account'

    #TODO: Ensure License Manager system requirements on redhat,centos
    case node['platform']
    when 'redhat', 'centos'
      ['glibc.i686'].each do |pckg|
        yum_package @new_resource.recipe_name + ':licensemanager:' + pckg do
          options '--enablerepo=*-optional'
          package_name pckg
          action :install
        end
      end
    when 'suse'
      #TODO: Ensure License Manager system requirements on suse
    else
      # NOTE: ArcGIS products are not officially supported on debian linux family
    end
  end
  
  new_resource.updated_by_last_action(true)
end

action :install do
  if node['platform'] == 'windows'
    cmd = @new_resource.setup
    args = "/qb ADDLOCAL=ALL INSTALLDIR=\"#{@new_resource.install_dir}\" INSTALLDIR1=\"#{@new_resource.python_dir}\""

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
    args = "/qb /x #{product_code}"

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
