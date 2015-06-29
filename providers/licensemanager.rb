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
  cmd = @new_resource.setup
  args = "/qb ADDLOCAL=ALL INSTALLDIR=\"#{@new_resource.install_dir}\" INSTALLDIR1=\"#{@new_resource.python_dir}\""

  install_dir = @new_resource.install_dir
  install_dir2 = install_dir.gsub(/\\/,'/')

  execute "Install ArcGIS License Manager" do
    command "\"#{cmd}\" #{args}"
    only_if {::Dir.glob("#{install_dir2}/License*").empty?}
  end
end
