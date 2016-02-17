#
# Cookbook Name:: arcgis
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

action :system do
  if node['platform'] == 'windows'
    #TODO: Ensure License Manager system requirements on Windows
  else
    #TODO: Ensure License Manager system requirements on Linux
  end
  
  new_resource.updated_by_last_action(true)
end

action :install do
  if node['platform'] == 'windows'
    cmd = @new_resource.setup
    args = "/qb ADDLOCAL=ALL INSTALLDIR=\"#{@new_resource.install_dir}\" INSTALLDIR1=\"#{@new_resource.python_dir}\""

    install_dir = @new_resource.install_dir
    install_dir2 = install_dir.gsub(/\\/,'/')

    execute 'Install ArcGIS License Manager' do
      command "\"#{cmd}\" #{args}"
      only_if {::Dir.glob("#{install_dir2}/License*").empty?}
    end
  else
    cmd = @new_resource.setup
    args  = "-m silent -l yes -d \"#{@new_resource.install_dir}\""
    install_subdir = ::File.join(@new_resource.install_dir, node['arcgis']['licensemanager']['install_subdir'])
    run_as_user = @new_resource.run_as_user

    subdir = @new_resource.install_dir
    node['arcgis']['licensemanager']['install_subdir'].split("/").each do |path|
      subdir = ::File.join(subdir, path)
      directory subdir do
        owner run_as_user
        group 'root'
        mode '0755'
        action :create
      end
    end

    %w{macrovision macrovision/storage}.each do |dir|
      directory "/usr/local/share/#{dir}" do
        owner run_as_user
        group 'root'
        mode '0755'
        action :create
      end
    end

    execute 'Install ArcGIS License Manager' do
      command "su - #{run_as_user} -c \"#{cmd} #{args}\""
      only_if {::Dir.glob("#{subdir}/License*").empty?}
    end

  end
  new_resource.updated_by_last_action(true)
end

action :uninstall do
  if node['platform'] == 'windows'
    install_dir = @new_resource.install_dir
    cmd = 'msiexec'
    product_code = @new_resource.product_code
    args = "/qb /x #{product_code}"

    execute 'Uninstall ArcGIS License Manager' do
      command "\"#{cmd}\" #{args}"
      only_if { Utils.product_installed?(product_code) }
    end
  else
   install_subdir = ::File.join(@new_resource.install_dir, node['arcgis']['licensemanager']['install_subdir']) 
   cmd = ::File.join(install_subdir, 'uninstallLicenseManager')
   args = "-s"

   execute 'Uninstall ArcGIS License Manager' do
     command "su - #{node['arcgis']['run_as_user']} -c \"#{cmd} #{args}\""
     only_if { ::File.exist?(cmd) }
   end
  end

  new_resource.updated_by_last_action(true)
end
