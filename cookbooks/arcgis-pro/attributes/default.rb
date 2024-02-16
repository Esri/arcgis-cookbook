#
# Cookbook Name:: arcgis-pro
# Attributes:: default
#
# Copyright 2015-2023 Esri
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

default['arcgis']['pro'].tap do |pro|
  case node['platform']
  when 'windows'
    pro['version'] = '3.2'

    pro['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                               'ArcGIS Pro ' + node['arcgis']['pro']['version'],
                               'ArcGISPro',
                               'ArcGISPro.msi').gsub('/', '\\')
    pro['blockaddins'] = '0'
    pro['portal_list'] = 'https://www.arcgis.com/'
    pro['allusers'] = 1
    pro['software_class'] = 'Viewer'
    pro['authorization_type'] = 'NAMED_USER'
    pro['esri_license_host'] = ENV['COMPUTERNAME']
    pro['authorization_file'] = ''
    pro['authorization_tool'] = ENV['ProgramW6432'] + '\\ArcGIS\\Pro\\bin\\SoftwareAuthorizationPro.exe'
    pro['lock_auth_settings'] = false

    pro['install_dir'] = if node['arcgis']['pro']['allusers'] == 2
                           ENV['USERPROFILE'] + '\\ArcGIS\\Pro'
                         else
                           ENV['ProgramW6432'] + '\\ArcGIS\\Pro'
                         end

    default['ms_dotnet']['version'] = '6.0.23'

    case node['arcgis']['pro']['version']
    when '3.2'
      pro['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                         'ArcGISPro_32_188049.exe').gsub('/', '\\')
      pro['product_code'] = '{76DFAD3E-96C5-4544-A6B4-3774DBF88B4E}' 
    when '3.1'
      pro['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                         'ArcGISPro_31_184994.exe').gsub('/', '\\')
      pro['product_code'] = '{A61AD307-865F-429F-B2A3-5618BD333F7E}' 
    when '3.0.3'
      pro['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                         'ArcGISPro_303_184244.exe').gsub('/', '\\')
      pro['product_code'] = '{690B606E-8A38-4CB9-B088-241F60A86072}' 
    when '3.0'
      pro['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                         'ArcGISPro_30_182209.exe').gsub('/', '\\')
      pro['product_code'] = '{FE78CD1B-4B17-4634-BBF7-3A597FFFAA69}' 
    when '2.9'
      pro['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                         'ArcGISPro_29_179927.exe').gsub('/', '\\')
      pro['product_code'] = '{AD53732E-507C-4A7F-B451-BE7EA01D0832}'
    when '2.8'
      pro['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                         'ArcGISPro_28_177688.exe').gsub('/', '\\')
      pro['product_code'] = '{26C745E6-B3C1-467B-9523-727D1803EE07}'
    when '2.7'
      pro['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                         'ArcGISPro_27_176624.exe').gsub('/', '\\')
      pro['product_code'] = '{FBBB144A-B4BE-49A0-95C4-1007E3A42FA5}'
    when '2.6'
      pro['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                         'ArcGISPro_26_175036.exe').gsub('/', '\\')
      pro['product_code'] = '{9D510CBA-7DB1-4E3D-8938-5E193DF406C9}'
    when '2.5'
      pro['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                         'ArcGISPro_25_172639.exe').gsub('/', '\\')
      pro['product_code'] = '{0D695F82-EB12-4430-A241-20226042FD40}'
    when '2.4'
      pro['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                         'ArcGISPro_24_169232.exe').gsub('/', '\\')
      pro['product_code'] = '{E3B1CE52-A1E6-4386-95C4-5AB450EF57BD}'
    when '2.3'
      pro['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                         'ArcGISPro_23_14527.exe').gsub('/', '\\')
      pro['product_code'] = '{9CB8A8C5-202D-4580-AF55-E09803BA1959}'
    when '2.2'
      pro['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                         'ArcGISPro_22_163783.exe').gsub('/', '\\')
      pro['product_code'] = '{A23CF244-D194-4471-97B4-37D448D2DE76}'
    when '2.1'
      pro['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                         'ArcGISPro_21_161559.exe').gsub('/', '\\')
      pro['product_code'] = '{0368352A-8996-4E80-B9A1-B1BA43FAE6E6}'
    when '2.0'
      pro['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                         'ArcGISPro_20_156181.exe').gsub('/', '\\')
      pro['product_code'] = '{28A4967F-DE0D-4076-B62D-A1A9EA62FF0A}'
    else
      Chef::Log.warn 'Unsupported ArcGIS Pro version'
    end

    pro['authorization_file_version'] = '11.2'

    case node['ms_dotnet']['version']
    when '6.0.23'
      default['ms_dotnet']['url'] = 'https://download.visualstudio.microsoft.com/download/pr/83d32568-c5a2-4117-9591-437051785f41/e75171da01b1fa5c796660dc4b96beed/windowsdesktop-runtime-6.0.23-win-x64.exe'
      default['ms_dotnet']['setup'] = ::File.join(node['arcgis']['repository']['archives'],
                                                  'windowsdesktop-runtime-6.0.23-win-x64.exe').gsub('/', '\\')
    when '6.0.5'
      default['ms_dotnet']['url'] = 'https://download.visualstudio.microsoft.com/download/pr/5681bdf9-0a48-45ac-b7bf-21b7b61657aa/bbdc43bc7bf0d15b97c1a98ae2e82ec0/windowsdesktop-runtime-6.0.5-win-x64.exe'
      default['ms_dotnet']['setup'] = ::File.join(node['arcgis']['repository']['archives'],
                                                  'windowsdesktop-runtime-6.0.5-win-x64.exe').gsub('/', '\\')
    when '4.8'
      default['ms_dotnet']['url'] = 'https://go.microsoft.com/fwlink/?linkid=2088631'
      default['ms_dotnet']['setup'] = ::File.join(node['arcgis']['repository']['archives'],
                                                  'ndp48-x86-x64-allos-enu.exe').gsub('/', '\\')
    else
      Chef::Log.warn 'Unsupported Microsoft .NET version'
    end
  else
    Chef::Log.warn "ArcGIS Pro is not supported on #{node['platform']} platform."
  end
end
