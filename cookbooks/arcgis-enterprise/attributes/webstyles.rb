#
# Cookbook Name:: arcgis-enterprise
# Attributes:: webstyles
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

default['arcgis']['webstyles'].tap do |webstyles|
  case node['platform']
  when 'windows'
    webstyles['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                     "ArcGIS #{node['arcgis']['version']}",
                                     'ArcGISWebStyles', 'Setup.exe').tr('/', '\\')

    case node['arcgis']['version']
    when '11.2'
      webstyles['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                               'Portal_for_ArcGIS_Web_Styles_Windows_112_188251.exe').tr('/', '\\')
      webstyles['product_code'] = '{0508DE8B-B6B2-42AD-B955-77451C3ACB60}'
    when '11.1'
      webstyles['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                               'Portal_for_ArcGIS_Web_Styles_Windows_111_185220.exe').tr('/', '\\')
      webstyles['product_code'] = '{67EDD399-CBD8-48C8-8B72-D79FBBBD79B2}'
    when '11.0'
      webstyles['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                               'Portal_for_ArcGIS_Web_Styles_Windows_110_182886.exe').tr('/', '\\')
      webstyles['product_code'] = '{CCA0635D-E306-4C42-AB81-F4032D731397}'
    when '10.9.1'
      webstyles['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                               'Portal_for_ArcGIS_Web_Styles_Windows_1091_180053.exe').tr('/', '\\')
      webstyles['product_code'] = '{2E63599E-08C2-4401-8FD7-95AAA64EA087}'
    when '10.9'
      webstyles['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                               'Portal_for_ArcGIS_Web_Styles_Windows_109_177787.exe').tr('/', '\\')
      webstyles['product_code'] = '{7748EA55-04FF-45E2-98EC-C78095AC25AA}'
    when '10.8.1'
      webstyles['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                               'Portal_for_ArcGIS_Web_Styles_Windows_1081_175215.exe').tr('/', '\\')
      webstyles['product_code'] = '{7748EA55-04FF-45E2-98EC-C78095AC25AA}'
    when '10.8'
      webstyles['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                               'Portal_for_ArcGIS_Web_Styles_Windows_108_172871.exe').tr('/', '\\')
      webstyles['product_code'] = '{EF31CB36-2EB4-4FD3-A451-AC12FD22A582}'
    else
      Chef::Log.warn 'Unsupported ArcGIS Web Styles version'
    end
  else # node['platform'] == 'linux'
    webstyles['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                     node['arcgis']['version'],
                                     'WebStyles', 'WebStyles-Setup.sh')

    case node['arcgis']['version']
    when '11.2'
      webstyles['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                               'Portal_for_ArcGIS_Web_Styles_Linux_112_188339.tar.gz')
    when '11.1'
      webstyles['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                               'Portal_for_ArcGIS_Web_Styles_Linux_111_185304.tar.gz')
    when '11.0'
      webstyles['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                               'Portal_for_ArcGIS_Web_Styles_Linux_110_182985.tar.gz')
    when '10.9.1'
      webstyles['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                               'Portal_for_ArcGIS_Web_Styles_Linux_1091_180201.tar.gz')
    when '10.9'
      webstyles['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                               'Portal_for_ArcGIS_Web_Styles_Linux_109_177886.tar.gz')
    when '10.8.1'
      webstyles['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                               'Portal_for_ArcGIS_Web_Styles_Linux_1081_175311.tar.gz')
    when '10.8'
      webstyles['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                               'Portal_for_ArcGIS_Web_Styles_Linux_108_172990.tar.gz')
    else
      Chef::Log.warn 'Unsupported ArcGIS Web Styles version'
    end
  end

  webstyles['setup_options'] = ''
end
