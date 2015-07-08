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

action :install do
  if node['platform'] == 'windows'
    cmd = @new_resource.setup
    args = "/qb ADDLOCAL=ALL INSTALLDIR=\"#{@new_resource.install_dir}\" INSTALLDIR1=\"#{@new_resource.python_dir}\""

    install_dir = @new_resource.install_dir
    install_dir2 = install_dir.gsub(/\\/,'/')

    execute "Install ArcGIS License Manager" do
      command "\"#{cmd}\" #{args}"
      only_if {::Dir.glob("#{install_dir2}/License*").empty?}
    end
  else
    cmd = @new_resource.setup
    args  = "-m silent -l yes -d \"#{@new_resource.install_dir}\""
    install_subdir = ::File.join(@new_resource.install_dir, node['licensemanager']['install_subdir'])
    run_as_user = @new_resource.run_as_user

    subdir = @new_resource.install_dir
    node['licensemanager']['install_subdir'].split("/").each do |path|
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

    execute "Install ArcGIS License Manager" do
      command "sudo -H -u #{node['arcgis']['run_as_user']} bash -c \"#{cmd} #{args}\""
      only_if {::Dir.glob("#{subdir}/License*").empty?}
    end

  end
  new_resource.updated_by_last_action(true)
end
