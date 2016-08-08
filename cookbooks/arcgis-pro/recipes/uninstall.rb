#
# Cookbook Name:: arcgis-pro
# Recipe:: uninstall
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

arcgis_pro_pro 'Uninstall ArcGIS Pro' do
  product_code node['arcgis']['pro']['product_code']
  only_if { Utils.product_installed?(node['arcgis']['pro']['product_code']) }
  action :uninstall
end
