#
# Cookbook Name:: arcgis-pro
# Attributes:: default
#
# Copyright 2015-2024 Esri
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
    pro['version'] = '3.4'

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

    default['ms_dotnet']['version'] = '8.0.3'

    case node['arcgis']['pro']['version']
    when '3.4'
      pro['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                         'ArcGISPro_34_192912.exe').gsub('/', '\\')
      pro['product_code'] = '{F6FDD729-EC3F-4361-A98E-B592EEF0D445}' 
    when '3.3'
      pro['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                         'ArcGISPro_33_190016.exe').gsub('/', '\\')
      pro['product_code'] = '{B43BC6C2-05D2-460B-AEE4-D15A9CA7B55E}' 
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
    else
      Chef::Log.warn 'Unsupported ArcGIS Pro version'
    end

    pro['authorization_file_version'] = '11.4'

    case node['ms_dotnet']['version']
    when '8.0.3'
      default['ms_dotnet']['url'] = 'https://download.visualstudio.microsoft.com/download/pr/51bc18ac-0594-412d-bd63-18ece4c91ac4/90b47b97c3bfe40a833791b166697e67/windowsdesktop-runtime-8.0.3-win-x64.exe'
      default['ms_dotnet']['setup'] = ::File.join(node['arcgis']['repository']['archives'],
                                                  'windowsdesktop-runtime-8.0.3-win-x64.exe').gsub('/', '\\')
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

    # Microsoft Edge WebView2 setup location
    default['webview2']['url'] = 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/4af8eb86-208b-4fb7-952b-af2a783d5c14/MicrosoftEdgeWebview2Setup.exe'
    default['webview2']['setup'] = ::File.join(node['arcgis']['repository']['archives'],
                                               'MicrosoftEdgeWebview2Setup.exe').gsub('/', '\\')
  else
    Chef::Log.warn "ArcGIS Pro is not supported on #{node['platform']} platform."
  end
end
