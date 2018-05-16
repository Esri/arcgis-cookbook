#
# Cookbook Name:: arcgis-desktop
# Attributes:: default
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

default['arcgis']['run_as_user'] = 'arcgis'
default['arcgis']['run_as_password'] = 'Pa$$w0rdPa$$w0rd'
default['arcgis']['version'] = '10.6'
default['arcgis']['desktop']['version'] = node['arcgis']['version']

case node['platform']
when 'windows'
  default['arcgis']['python']['install_dir'] = 'C:\\Python27'

  default['arcgis']['desktop']['setup'] = 'C:\\ArcGIS\\Desktop\\Setup.exe'
  default['arcgis']['desktop']['lp-setup'] = 'C:\\ArcGIS\\DesktopLP\\SetupFiles\\setup.msi'
  default['arcgis']['desktop']['install_dir'] = ENV['ProgramFiles(x86)'] + '\\ArcGIS'
  default['arcgis']['desktop']['install_features'] = 'ALL'
  default['arcgis']['desktop']['authorization_file'] = ''
  default['arcgis']['desktop']['authorization_tool'] = ENV['ProgramFiles(x86)'] + '\\Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe'
  default['arcgis']['desktop']['esri_license_host'] = ENV['COMPUTERNAME']
  default['arcgis']['desktop']['software_class'] = 'Viewer'
  default['arcgis']['desktop']['seat_preference'] = 'Fixed'
  default['arcgis']['desktop']['desktop_config'] = true
  default['arcgis']['desktop']['modifyflexdacl'] = false

  default['arcgis']['licensemanager']['setup'] = 'C:\\ArcGIS\\LicenseManager\\Setup.exe'
  default['arcgis']['licensemanager']['lp-setup'] = 'C:\\ArcGIS\\LicenseManager\\SetupFiles\\setup.msi'
  default['arcgis']['licensemanager']['install_dir'] = ENV['ProgramFiles(x86)'] + '\\ArcGIS'

  case node['arcgis']['desktop']['version']
  when '10.6'
    default['arcgis']['desktop']['product_code'] = '{F8206086-367E-44E4-9E24-92E9E057A63D}'
    default['arcgis']['licensemanager']['product_code'] = '{D6AF20B5-825F-44A9-915D-C2868CBD59F3}'
  when '10.5.1'
    default['arcgis']['desktop']['product_code'] = '{4740FC57-60FE-45BB-B513-3309F6B73183}'
    default['arcgis']['licensemanager']['product_code'] = '{DF06C3DC-54B5-49A1-9756-B68FD65A0AD0}'
  when '10.5'
    default['arcgis']['desktop']['product_code'] = '{76B58799-3448-4DE4-BA71-0FDFAA2A2E9A}'
    default['arcgis']['licensemanager']['product_code'] = '{3A024FEA-3E14-4257-87D0-8FCA03257560}'
  when '10.4.1'
    default['arcgis']['desktop']['product_code'] = '{CB0C9578-75CB-45E5-BD81-A600BA33B0C3}'
    default['arcgis']['licensemanager']['product_code'] = '{D71379AF-A72B-4B10-A7BA-64BC6AF6841B}'
  when '10.4'
    default['arcgis']['desktop']['product_code'] = '{72E7DF0D-FFEE-43CE-A5FA-43DFC25DC087}'
    default['arcgis']['licensemanager']['product_code'] = '{E1393226-725C-42F8-A672-4E5AC55EFBDE}'
  else
    throw 'Unsupported ArcGIS version'
  end

  default['arcgis']['desktop']['authorization_file_version'] = node['arcgis']['desktop']['version'].to_f.to_s
else # node['platform'] == 'linux'
  default['arcgis']['licensemanager']['install_subdir'] = 'arcgis/license' + node['arcgis']['version']
  default['arcgis']['licensemanager']['setup'] = '/tmp/licensemanager-cd/Setup'
  default['arcgis']['licensemanager']['install_dir'] = '/'
  default['arcgis']['python']['install_dir'] = '' # Not Needed on Linux
end
