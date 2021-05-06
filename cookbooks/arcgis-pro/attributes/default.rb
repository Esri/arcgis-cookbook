#
# Cookbook Name:: arcgis-pro
# Attributes:: default
#
# Copyright 2015-2021 Esri
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
    pro['version'] = '2.7'

    pro['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                               'ArcGIS Pro ' + node['arcgis']['pro']['version'],
                               'ArcGISPro',
                               'ArcGISPro.msi').gsub('/', '\\')
    pro['install_dir'] = ENV['ProgramW6432'] + '\\ArcGIS\\Pro'
    pro['blockaddins'] = '#0'
    pro['portal_list'] = 'https://www.arcgis.com/'
    pro['allusers'] = 2
    pro['software_class'] = 'Viewer'
    pro['authorization_type'] = 'NAMED_USER'
    pro['esri_license_host'] = ENV['COMPUTERNAME']
    pro['authorization_file'] = ''
    pro['authorization_tool'] = ENV['ProgramW6432'] + '\\ArcGIS\\Pro\\bin\\SoftwareAuthorizationPro.exe'

    case node['arcgis']['pro']['version']
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

    pro['authorization_file_version'] = node['arcgis']['pro']['version'].to_f.to_s
  else
    Chef::Log.warn "ArcGIS Pro is not supported on #{node['platform']} platform."
  end
end
