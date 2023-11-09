#
# Cookbook Name:: arcgis-desktop
# Recipe:: licensemanager
#
# Copyright 2023 Esri
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

arcgis_desktop_licensemanager 'Verify ArcGIS License Manager system requirements' do
  action :system
end

arcgis_desktop_licensemanager 'Unpack ArcGIS License Manager Setup' do
  setup_archive node['arcgis']['licensemanager']['setup_archive']
  setups_repo node['arcgis']['repository']['setups']
  only_if { ::File.exist?(node['arcgis']['licensemanager']['setup_archive']) &&
            !::File.exist?(node['arcgis']['licensemanager']['setup']) }
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['licensemanager']['product_code']) }
  end
  action :unpack
end

arcgis_desktop_licensemanager 'Install ArcGIS License Manager' do
  setup node['arcgis']['licensemanager']['setup']
  product_code node['arcgis']['licensemanager']['product_code']
  install_dir node['arcgis']['licensemanager']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['licensemanager']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                               node['hostname'],
                                               node['arcgis']['licensemanager']['version'],
                                               :LicenseManager) }
  end
  action :install
end
