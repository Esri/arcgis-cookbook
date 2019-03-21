#
# Cookbook Name:: arcgis-desktop
# Attributes:: desktop
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

default['arcgis']['desktop'].tap do |desktop|

  case node['platform']
  when 'windows'
    desktop['setup_archive'] = ''
    desktop['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                   'ArcGIS ' + node['arcgis']['version'],
                                   'Desktop', 'Setup.exe')
    desktop['lp-setup'] = 'C:\\ArcGIS\\DesktopLP\\SetupFiles\\setup.msi'
    desktop['install_dir'] = ENV['ProgramFiles(x86)'] + '\\ArcGIS'
    desktop['install_features'] = 'ALL'
    desktop['authorization_tool'] = ENV['ProgramFiles(x86)'] + '\\Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe'
    desktop['esri_license_host'] = ENV['COMPUTERNAME']
    desktop['software_class'] = 'Viewer'
    desktop['seat_preference'] = 'Fixed'
    desktop['desktop_config'] = true
    desktop['modifyflexdacl'] = false

    desktop['authorization_file'] = ''
    desktop['authorization_file_version'] = node['arcgis']['version'].to_f.to_s

    case node['arcgis']['version']
    when '10.7'
      desktop['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                             'ArcGIS_Desktop_107_167519.exe').gsub('/', '\\')
      desktop['product_code'] = '{BFB4F32E-38DF-4E8F-8180-C99FC9A14BBE}'
    when '10.6.1'
      desktop['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                             'ArcGIS_Desktop_1061_163864.exe').gsub('/', '\\')
      desktop['product_code'] = '{FA2E2CBC-0697-4C71-913E-8C65B5A611E8}'
    when '10.6'
      desktop['product_code'] = '{F8206086-367E-44E4-9E24-92E9E057A63D}'
    when '10.5.1'
      desktop['product_code'] = '{4740FC57-60FE-45BB-B513-3309F6B73183}'
    when '10.5'
      desktop['product_code'] = '{76B58799-3448-4DE4-BA71-0FDFAA2A2E9A}'
    when '10.4.1'
      desktop['product_code'] = '{CB0C9578-75CB-45E5-BD81-A600BA33B0C3}'
    when '10.4'
      desktop['product_code'] = '{72E7DF0D-FFEE-43CE-A5FA-43DFC25DC087}'
    else
      Chef::Log.warn 'Unsupported ArcGIS Desktop version'
    end
  else # node['platform'] == 'linux'
    Chef::Log.warn "ArcGIS Desktop is not supported on #{node['platform']} platform."
  end

end
