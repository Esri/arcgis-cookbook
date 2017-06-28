#
# Cookbook Name:: arcgis-enterprise
# Provider:: patches
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

use_inline_resources if defined?(use_inline_resources)

action :install do
  if node['platform'] == 'windows'
    # Dir.glob() doesn't support backslashes within a path, so they will be replaces on Windows
    patch_folder = node['arcgis']['patches']['local_patch_folder'].gsub('\\','/')

    # get all patches  within the specified folder and register them
    Dir.glob("#{patch_folder}/**/*").each do |patch|
      windows_package "Install #{patch}" do
        action :install
        source patch
        installer_type :custom
        options '/qn'
      end
    end

    new_resource.updated_by_last_action(true)
  else
    # patch_folder = node["arcgis"]["patches"]["local_patch_folder"]

    throw "This function is not yet supported on this platform."
  end
end