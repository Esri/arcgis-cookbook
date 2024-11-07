#
# Cookbook Name:: arcgis-license-manager
# Attributes:: default
#
# Copyright 2024 Esri
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

include_attribute 'arcgis-repository'

default['arcgis']['run_as_user'] = 'arcgis'
default['arcgis']['run_as_password'] = nil

default['arcgis']['licensemanager'].tap do |licensemanager|
  licensemanager['version'] = '2024.1'
  licensemanager['packages'] = []

  case node['platform']
  when 'windows'
    licensemanager['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  'ArcGIS License Manager ' + node['arcgis']['licensemanager']['version'],
                                  'LicenseManager', 'Setup.exe')
    licensemanager['lp-setup'] = 'C:\\ArcGIS\\LicenseManager\\SetupFiles\\setup.msi'
    licensemanager['install_dir'] = ENV['ProgramFiles(x86)'] + '\\ArcGIS'

    case node['arcgis']['licensemanager']['version']
    when '2024.1'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Windows_2024_1_192691.exe').gsub('/', '\\')
      licensemanager['product_code'] = '{2BCB59D3-E25C-4F17-8C94-121A12B68A6C}'
    when '2024.0'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Windows_2024_0_190004.exe').gsub('/', '\\')
      licensemanager['product_code'] = '{D9D91CDE-048A-47B5-AFE7-FB397DAF87D9}'
    when '2023.0'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Windows_2023_0_187870.exe').gsub('/', '\\')
      licensemanager['product_code'] = '{C5E546F7-5E07-4AAB-A367-15FF52D0C683}'
    when '2022.1'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Windows_2022_1_184717.exe').gsub('/', '\\')
      licensemanager['product_code'] = '{96804860-2C2F-4448-AE47-76CB160AD043}'
    when '2022.0'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Windows_2022_0_182116.exe').gsub('/', '\\')
      licensemanager['product_code'] = '{A3AC9C93-E045-4CAE-AAE4-F62A8E669E02}'
    when '2021.1'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Windows_2021_1_180127.exe').gsub('/', '\\')
      licensemanager['product_code'] = '{DA36A877-1BF2-4E28-9CE3-D3A07FB645A3}'      
    else
      Chef::Log.warn 'Unsupported ArcGIS License Manager version'
    end
  else # node['platform'] == 'linux'
    licensemanager['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                          node['arcgis']['licensemanager']['version'],
                                          'Setup')

    licensemanager['install_dir'] = '/'
    licensemanager['install_subdir'] = 'arcgis/license' + node['arcgis']['licensemanager']['version']

    case node['arcgis']['licensemanager']['version']
    when '2024.1'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Linux_2024_1_192720.tar.gz')
    when '2024.0'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Linux_2024_0_190033.tar.gz')
    when '2023.0'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Linux_2023_0_187909.tar.gz')
    when '2022.1'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Linux_2022_1_184756.tar.gz')
      licensemanager['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                            node['arcgis']['licensemanager']['version'],
                                            'LicenseManager_Linux', 'Setup')
    when '2022.0'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Linux_2022_0_182145.tar.gz')
      licensemanager['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                            node['arcgis']['licensemanager']['version'],
                                            'LicenseManager_Linux', 'Setup')
    when '2021.1'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Linux_2021_1_180145.tar.gz')      
      licensemanager['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                            node['arcgis']['licensemanager']['version'],
                                            'LicenseManager_Linux', 'Setup')
    else
      Chef::Log.warn 'Unsupported ArcGIS License Manager version'
    end
  end
end
