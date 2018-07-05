#
# Cookbook Name:: arcgis-desktop
# Attributes:: default
#
# Copyright 2018 Esri
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

default['arcgis']['run_as_user'] = 'arcgis'
default['arcgis']['run_as_password'] = 'Pa$$w0rdPa$$w0rd'
default['arcgis']['version'] = '10.6.1'

case node['platform']
when 'windows'
  default['arcgis']['repository']['setups'] = ENV['USERPROFILE'] + '\\Documents'
  default['arcgis']['python']['install_dir'] = 'C:\\Python27'
else # node['platform'] == 'linux'
  default['arcgis']['repository']['setups'] = '/opt/arcgis'
  default['arcgis']['python']['install_dir'] = '' # Not Needed on Linux
end
