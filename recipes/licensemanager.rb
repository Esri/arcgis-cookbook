#
# Cookbook Name:: arcgis
# Recipe:: licensemanager
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

arcgis_licensemanager 'Verify ArcGIS License Manager system requirements' do
  action :system
end

arcgis_licensemanager 'Install ArcGIS License Manager' do
  setup node['arcgis']['licensemanager']['setup']
  install_dir node['arcgis']['licensemanager']['install_dir']
  python_dir node['arcgis']['python']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  action :install
end
