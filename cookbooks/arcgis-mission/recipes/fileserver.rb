# Cookbook Name:: arcgis-mission
# Recipe:: fileserver
#
# Copyright 2019 Esri
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

if node['platform'] != 'windows'
  node['arcgis']['mission_server']['shares'].each do |share|
    directory share do
      owner node['arcgis']['run_as_user']
      mode '0700'
      recursive true
      action :create
    end

    nfs_export share do
      network '*'
      writeable true
      sync true
      options ['insecure', 'no_subtree_check', 'nohide', 'no_root_squash']
    end
  end
end