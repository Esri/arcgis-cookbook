#
# Cookbook Name:: arcgis-insights
# Attributes:: default
#
# Copyright 2017 Esri
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
  insights['version'] = '2020.3'

  case node['platform']
  when 'windows'
    insights['setup'] = node['arcgis']['repository']['setups'] + '\\ArcGIS Insights Windows ' +
                        node['arcgis']['insights']['version'] + '\\Insights\\Setup.exe'

    case node['arcgis']['insights']['version']
    when '2020.3'
      insights['product_code'] = '{A423A99B-D785-49F9-B91B-E39457B6B6D5}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Windows_2020_3_176134.exe')
    when '2020.2'
      insights['product_code'] = '{A51F92FD-3A9D-467C-B29F-74759CB85E0A}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Windows_2020_2_175863.exe')
      insights['setup'] = node['arcgis']['repository']['setups'] + '\\ArcGIS Insights ' +
                          node['arcgis']['insights']['version'] + '\\Insights\\Setup.exe'
    when '2020.1'
      insights['product_code'] = '{5293D733-7F85-48C8-90A2-7506E51773DB}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Windows_2020_1_173526.exe')
      insights['setup'] = node['arcgis']['repository']['setups'] + '\\ArcGIS Insights ' +
                          node['arcgis']['insights']['version'] + '\\Insights\\Setup.exe'
    when '3.4.1'
      insights['product_code'] = '{F3B91D92-3DD8-4F0B-B43B-6F9DA2C1830A}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'ArcGIS_Insights_Windows_341_171410.exe')
      insights['setup'] = node['arcgis']['repository']['setups'] + '\\Insights for ArcGIS 3.4.1\\Insights\\Setup.exe'
    else
      Chef::Log.warn 'Unsupported Insights for ArcGIS version'
    end
  else # node['platform'] == 'linux'
    insights['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                    node['arcgis']['insights']['version'],
                                    'Insights/Insights-Setup.sh')

    case node['arcgis']['insights']['version']
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
