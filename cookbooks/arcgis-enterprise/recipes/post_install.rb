#
# Cookbook Name:: arcgis-enterprise
# Recipe:: post_install
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

execute 'Execute post-install script' do
  command node['arcgis']['post_install_script']
  only_if { ::File.exist?(node['arcgis']['post_install_script']) }
  ignore_failure true
  action :run
end

