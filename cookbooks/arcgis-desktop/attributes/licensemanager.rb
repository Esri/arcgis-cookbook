#
# Cookbook Name:: arcgis-desktop
# Attributes:: licensemanager
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

default['arcgis']['licensemanager'].tap do |licensemanager|
  licensemanager['version'] = '2023.0'

  case node['platform']
  when 'windows'
    licensemanager['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  'ArcGIS License Manager ' + node['arcgis']['licensemanager']['version'],
                                  'LicenseManager', 'Setup.exe')
    licensemanager['lp-setup'] = 'C:\\ArcGIS\\LicenseManager\\SetupFiles\\setup.msi'
    licensemanager['install_dir'] = ENV['ProgramFiles(x86)'] + '\\ArcGIS'

    case node['arcgis']['licensemanager']['version']
    when '2023.0'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Windows_2023_0_187870.exe').gsub('/', '\\')
      licensemanager['product_code'] = 'C5E546F7-5E07-4AAB-A367-15FF52D0C683'
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
    when '2021.0'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Windows_2021_0_177928.exe').gsub('/', '\\')
      licensemanager['product_code'] = '{9DDD72DA-75D2-4FB0-BC19-25F8B53254FF}'      
    when '2020.1'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Windows_2020_1_176572.exe').gsub('/', '\\')
      licensemanager['product_code'] = '{3C9B5AFE-057B-47B3-83A6-D348ABAC3E14}'
    when '2020.0'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Windows_2020_0_175435.exe').gsub('/', '\\')
      licensemanager['product_code'] = '{F89EA66A-6AC2-401C-B8A0-E3ABDB5EDC10}'
    when '2019.2'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Windows_2019_2_173083.exe').gsub('/', '\\')
      licensemanager['product_code'] = '{77F1D4EB-0225-4626-BB9E-7FCB4B0309E5}'
      licensemanager['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  'License Manager ' + node['arcgis']['licensemanager']['version'],
                                  'LicenseManager', 'Setup.exe')
    when '2019.1'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Windows_2019_1_172308.exe').gsub('/', '\\')
      licensemanager['product_code'] = '{BA3C546E-6FAC-405C-B2C9-30BC6E26A7A9}'
      licensemanager['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  'License Manager ' + node['arcgis']['licensemanager']['version'],
                                  'LicenseManager', 'Setup.exe')
    when '2019.0'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Windows_2019_0_169344.exe').gsub('/', '\\')
      licensemanager['product_code'] = '{CB1E78B5-9914-45C6-8227-D55F4CD5EA6F}'
      licensemanager['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  'License Manager ' + node['arcgis']['licensemanager']['version'],
                                  'LicenseManager', 'Setup.exe')
    when '2018.1'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Windows_2018_1_167080.exe').gsub('/', '\\')
      licensemanager['product_code'] = '{E1C26E47-C6AB-4120-A3DE-2FA0F723C876}'
      licensemanager['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  'License Manager ' + node['arcgis']['licensemanager']['version'],
                                  'LicenseManager', 'Setup.exe')
    when '2018.0'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Windows_2018_0_163304.exe').gsub('/', '\\')
      licensemanager['product_code'] = '{CFF43ACB-9B0C-4725-B489-7F969F5B90AB}'
      licensemanager['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  'License Manager ' + node['arcgis']['licensemanager']['version'],
                                  'LicenseManager', 'Setup.exe')
    else
      Chef::Log.warn 'Unsupported ArcGIS License Manager version'
    end
  else # node['platform'] == 'linux'
    licensemanager['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                          node['arcgis']['licensemanager']['version'],
                                          'LicenseManager_Linux', 'Setup')
    licensemanager['install_dir'] = '/'
    licensemanager['install_subdir'] = 'arcgis/license' + node['arcgis']['licensemanager']['version']

    case node['arcgis']['licensemanager']['version']
    when '2023.0'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Linux_2023_0_187909.tar.gz')
      licensemanager['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                            node['arcgis']['licensemanager']['version'],
                                            'Setup')
    when '2022.1'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Linux_2022_1_184756.tar.gz')
    when '2022.0'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Linux_2022_0_182145.tar.gz')
    when '2021.1'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Linux_2021_1_180145.tar.gz')      
    when '2021.0'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Linux_2021.0_177950.tar.gz')      
    when '2020.1'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Linux_2020_1_176584.tar.gz')
    when '2020.0'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Linux_2020_0_174031.tar.gz')
    when '2019.2'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Linux_2019_2_173095.tar.gz')
    when '2019.1'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Linux_2019_1_172320.tar.gz')
    when '2019.0'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Linux_2019_0_169356.tar.gz')
    when '2018.1'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Linux_2018_1_167092.tar.gz')
    when '2018.0'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Linux_2018_0_163516.tar.gz')
    else
      Chef::Log.warn 'Unsupported ArcGIS License Manager version'
    end
  end
end
