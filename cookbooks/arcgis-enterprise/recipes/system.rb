#
# Cookbook Name:: arcgis-enterprise
# Recipe:: system
#
# Copyright 2022 Esri
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

chef_gem 'multipart-post' do
  ignore_failure true
  compile_time true
end

if platform?('windows')
  user node['arcgis']['run_as_user'] do
    comment 'ArcGIS user account'
    manage_home true
    password node['arcgis']['run_as_password']
    not_if { node['arcgis']['run_as_user'].include? '\\' } # do not try to create domain accounts
    action :create
  end
else
  node['arcgis']['packages'].each do |package_install|
    package package_install
  end 

  group node['arcgis']['run_as_user'] do
    gid node['arcgis']['run_as_gid']
    not_if "getent group #{node['arcgis']['run_as_user']}"
    action :create
  end

  user node['arcgis']['run_as_user'] do
    comment 'ArcGIS user account'
    manage_home true
    home '/home/' + node['arcgis']['run_as_user']
    shell '/bin/bash'
    uid node['arcgis']['run_as_uid']
    gid node['arcgis']['run_as_gid']
    not_if "getent passwd #{node['arcgis']['run_as_user']}"
    action :create
  end

  ['hard', 'soft'].each do |t|
    set_limit node['arcgis']['run_as_user'] do
      type t
      item 'nofile'
      value 65536
    end

    set_limit node['arcgis']['run_as_user'] do
      type t
      item 'nproc'
      value 25059
    end

    set_limit node['arcgis']['run_as_user'] do
      type t
      item 'memlock'
      value 'unlimited'
    end

    set_limit node['arcgis']['run_as_user'] do
      type t
      item 'fsize'
      value 'unlimited'
    end

    set_limit node['arcgis']['run_as_user'] do
      type t
      item 'as'
      value 'unlimited'
    end
  end

  # Rename ~/.ESRI.properties.<hostname>.<version> files to include
  # the correct hostname
  script 'Rename .ESRI.properties.*.* files' do
    interpreter 'bash'
    user node['arcgis']['run_as_user']
    cwd '/home/' + node['arcgis']['run_as_user']
    code <<-EOH
      for file in /home/arcgis/.ESRI.properties.* ; do
        oldhost=$(echo $file | cut -d'.' -f 4)
        newhost=$(hostname)
        newfile=$(echo $file | sed -e "s,$oldhost,$newhost,g")
        if [ ! -f $newfile ]; then
          mv $file $newfile
        fi
      done
    EOH
    only_if { ENV['arcgis_cloud_platform'] == 'aws' }
  end

  # Remove comment from #/net in /etc/auto.master
  file "/etc/auto.master" do
    content lazy { IO.read("/etc/auto.master").gsub("#/net", "/net") }
    only_if { node['arcgis']['configure_autofs'] }
  end

  service 'autofs' do
    only_if { node['arcgis']['configure_autofs'] }
    action [:enable, :reload, :restart]
  end
end

include_recipe 'arcgis-enterprise::hosts'
