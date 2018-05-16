#
# Cookbook Name:: arcgis-desktop
# Provider:: user
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

use_inline_resources if defined?(use_inline_resources)

action :create do
  if platform?('windows')
    user node['arcgis']['run_as_user'] do
      comment 'ArcGIS user account'
      manage_home true
      password node['arcgis']['run_as_password']
      not_if { node['arcgis']['run_as_user'].include? '\\' } # do not try to create domain accounts
      action :create
    end
  else
    user @new_resource.name do
      username node['arcgis']['run_as_user']
      comment 'ArcGIS user account'
      manage_home true
      home '/home/' + node['arcgis']['run_as_user']
      action :create
    end

    ['hard', 'soft'].each do |t|
      set_limit node['arcgis']['run_as_user'] do
        type t
        item 'nofile'
        value 65535
        use_system true
      end

      set_limit node['arcgis']['run_as_user'] do
        type t
        item 'nproc'
        value 25059
        use_system true
      end
    end
  end

  new_resource.updated_by_last_action(true)
end
