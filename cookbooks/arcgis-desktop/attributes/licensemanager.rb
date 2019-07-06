#
# Cookbook Name:: arcgis-desktop
# Attributes:: licensemanager
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

default['arcgis']['licensemanager'].tap do |licensemanager|
  case node['platform']
  when 'windows'
    licensemanager['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  'ArcGIS ' + node['arcgis']['version'],
                                  'LicenseManager', 'Setup.exe')
    licensemanager['lp-setup'] = 'C:\\ArcGIS\\LicenseManager\\SetupFiles\\setup.msi'
    licensemanager['install_dir'] = ENV['ProgramFiles(x86)'] + '\\ArcGIS'

    case node['arcgis']['version']
    when '10.7'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Windows_2018_1_167080.exe').gsub('/', '\\')
      licensemanager['product_code'] = '{E1C26E47-C6AB-4120-A3DE-2FA0F723C876}'
    when '10.6.1'
      licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                    'ArcGIS_License_Manager_Windows_2018_0_163304.exe').gsub('/', '\\')
      licensemanager['product_code'] = '{1914B5D6-02C2-4CA3-9CAB-EE76358228CF}'
    when '10.6'
      licensemanager['product_code'] = '{D6AF20B5-825F-44A9-915D-C2868CBD59F3}'
    when '10.5.1'
      licensemanager['product_code'] = '{DF06C3DC-54B5-49A1-9756-B68FD65A0AD0}'
    when '10.5'
      licensemanager['product_code'] = '{3A024FEA-3E14-4257-87D0-8FCA03257560}'
    when '10.4.1'
      licensemanager['product_code'] = '{D71379AF-A72B-4B10-A7BA-64BC6AF6841B}'
    when '10.4'
      licensemanager['product_code'] = '{E1393226-725C-42F8-A672-4E5AC55EFBDE}'
    else
      Chef::Log.warn 'Unsupported ArcGIS version'
    end
  else # node['platform'] == 'linux'
    licensemanager['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                          node['arcgis']['version'],
                                          'licensemanager', 'Setup')
    licensemanager['install_dir'] = '/'
    licensemanager['install_subdir'] = 'arcgis/license' + node['arcgis']['version']

    licensemanager['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                  'ArcGIS_License_Manager_Linux_2018_1_167092.tar.gz')
  end
end
