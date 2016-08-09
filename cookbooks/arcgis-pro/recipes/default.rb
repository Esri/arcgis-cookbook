#
# Cookbook Name:: arcgis-pro
# Recipe:: pro
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

arcgis_pro_pro 'Verify ArcGIS Pro system requirements' do
  action :system
end

arcgis_pro_pro 'Install ArcGIS Pro' do
  setup node['arcgis']['pro']['setup']
  install_dir node['arcgis']['pro']['install_dir']
  not_if { Utils.product_installed?(node['arcgis']['pro']['product_code']) }
  action :install
end
