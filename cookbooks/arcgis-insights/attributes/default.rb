#
# Cookbook Name:: arcgis-insights
# Attributes:: default
#
# Copyright 2021 Esri
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
include_attribute 'arcgis-enterprise'

default['arcgis']['insights'].tap do |insights|
  insights['version'] = '2021.3.1'

  case node['platform']
  when 'windows'
    insights['setup'] = node['arcgis']['repository']['setups'] + '\\ArcGIS Insights ' +
                        node['arcgis']['insights']['version'] + '\\Insights\\Setup.exe'

    case node['arcgis']['insights']['version']
    when '2021.3.1'
      insights['product_code'] = '{2EFCCCED-8C84-4A76-B2B7-4680195E9FD4}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Windows_2021_3_1_179500.exe')
    when '2021.3'
      insights['product_code'] = '{64066B1D-7BF6-42DD-98F1-03D5146EC890}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Windows_2021_3_179498.exe')
    when '2021.2.1'
      insights['product_code'] = '{749A02F9-D417-449A-9AF5-1D116E080790}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Windows_2021_2_1_178737.exe')
    when '2021.2'
      insights['product_code'] = '{E7C79A1B-DB5E-48A9-846B-B648FCAD7A12}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Windows_2021_2_178735.exe')
    when '2021.1.1'
      insights['product_code'] = '{67E5DAD3-A014-44D7-9CF1-35AF8C7117D4}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Windows_2021_1_1_177961.exe')
    when '2021.1'
      insights['product_code'] = '{6C55A753-1D58-4BD6-BD2E-7D57433F835E}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Windows_2021_1_177919.exe')
    when '2020.3'
      insights['product_code'] = '{A423A99B-D785-49F9-B91B-E39457B6B6D5}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Windows_2020_3_176134.exe')
      insights['setup'] = node['arcgis']['repository']['setups'] + '\\ArcGIS Insights Windows ' +
                          node['arcgis']['insights']['version'] + '\\Insights\\Setup.exe'
    when '2020.2'
      insights['product_code'] = '{A51F92FD-3A9D-467C-B29F-74759CB85E0A}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Windows_2020_2_175863.exe')
    when '2020.1'
      insights['product_code'] = '{5293D733-7F85-48C8-90A2-7506E51773DB}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Windows_2020_1_173526.exe')
    when '3.4.1'
      insights['product_code'] = '{F3B91D92-3DD8-4F0B-B43B-6F9DA2C1830A}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Windows_341_171410.exe')
    else
      Chef::Log.warn 'Unsupported Insights for ArcGIS version'
    end
  else # node['platform'] == 'linux'
    insights['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                    node['arcgis']['insights']['version'],
                                    'Insights/Insights-Setup.sh')

    case node['arcgis']['insights']['version']
    when '2021.3.1'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Linux_2021_3_1_179511.tar.gz')
    when '2021.3'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Linux_2021_3_179499.tar.gz')
    when '2021.2.1'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Linux_2021_2_1_178738.tar.gz')
    when '2021.2'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Linux_2021_2_178736.tar.gz')
    when '2021.1.1'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Linux_2021_1_1_177962.tar.gz')
    when '2021.1'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Linux_2021_1_177920.tar.gz')
    when '2020.3'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Linux_2020_3_176135.tar.gz')
    when '2020.2'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Linux_2020_2_175864.tar.gz')
    when '2020.1'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Linux_2020_1_173527.tar.gz')
    when '3.4.1'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Linux_341_171471.tar.gz')
    else
      Chef::Log.warn 'Unsupported Insights for ArcGIS version'
    end
  end
end
