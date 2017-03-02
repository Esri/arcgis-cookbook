#
# Cookbook Name:: arcgis-desktop
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

arcgis_desktop_desktop 'Uninstall ArcGIS Desktop' do
  product_code node['arcgis']['desktop']['product_code']
  install_dir node['arcgis']['desktop']['install_dir']
  only_if { Utils.product_installed?(node['arcgis']['desktop']['product_code']) }
  action :uninstall
end

arcgis_desktop_licensemanager 'Uninstall ArcGIS License Manager' do
  product_code node['arcgis']['licensemanager']['product_code']
  install_dir node['arcgis']['licensemanager']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  if node['platform'] == 'windows'
    only_if { Utils.product_installed?(node['arcgis']['licensemanager']['product_code']) }
  else
    only_if { 
      subdir = ::File.join(node['arcgis']['licensemanager']['install_dir'],
                           node['arcgis']['licensemanager']['install_subdir'])
      !::Dir.glob("#{subdir}/License*").empty? 
    }
  end
  action :uninstall
end
