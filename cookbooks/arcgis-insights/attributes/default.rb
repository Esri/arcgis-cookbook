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
  insights['version'] = '3.2.1'

  case node['platform']
  when 'windows'
    insights['setup'] = node['arcgis']['repository']['setups'] + '\\Insights for ArcGIS ' +
                        node['arcgis']['insights']['version'] + '\\Insights\\Setup.exe'

    case node['arcgis']['insights']['version']
    when '3.2.1'
      insights['product_code'] = '{451E8919-F60D-47DD-B5CF-7BC97F8E9FE5}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'Insights_for_ArcGIS_Windows_321_168370.exe')
    when '3.2'
      insights['product_code'] = '{01F700EA-D707-41BF-AC1A-DFB82FAF84AC}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'Insights_for_ArcGIS_Windows_32_168464.exe')
    when '3.1'
      insights['product_code'] = '{ECDBB436-78D3-4CAD-868D-4D39C958AE11}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'Insights_for_ArcGIS_Windows_31_166715.exe')
    when '3.0'
      insights['product_code'] = '{E02D396E-6030-4B44-BAB1-BB7C9D586EC1}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'Insights_for_ArcGIS_Windows_30_164976.exe')
    when '2.3'
      insights['product_code'] = '{79FBD411-5574-417E-AAAC-D8859B761C10}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'Insights_for_ArcGIS_Windows_23_163450.exe')
    when '2.2.1'
      insights['product_code'] = '{00BA08F3-B462-43AF-BFFA-9E17C1B9667D}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'Insights_for_ArcGIS_Windows_221_161935.exe')
    when '2.1'
      insights['product_code'] = '{0FDA7094-6094-49B9-94C9-F06D6B22954F}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'Insights_for_ArcGIS_Windows_21_159479.exe')
    when '2.0'
      insights['product_code'] = '{C7CDC991-B121-4A94-85AF-31688E61F415}'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'Insights_for_ArcGIS_Windows_20_157378.exe')
    else
      Chef::Log.warn 'Unsupported Insights for ArcGIS version'
    end
  else # node['platform'] == 'linux'
    insights['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                    node['arcgis']['insights']['version'],
                                    'Insights/Insights-Setup.sh')

    case node['arcgis']['insights']['version']
    when '3.2.1'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'Insights_for_ArcGIS_Linux_321_168491.tar.gz')
    when '3.2'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'Insights_for_ArcGIS_Linux_32_168465.tar.gz')
    when '3.1'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'Insights_for_ArcGIS_Linux_31_166716.tar.gz')
    when '3.0'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'Insights_for_ArcGIS_Linux_30_164977.tar.gz')
    when '2.3'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'Insights_for_ArcGIS_Linux_23_163451.tar.gz')
    when '2.2.1'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'Insights_for_ArcGIS_Linux_221_161936.tar.gz')
    when '2.1'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'Insights_for_ArcGIS_Linux_21_159551.tar.gz')
    when '2.0'
      insights['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                              'Insights_for_ArcGIS_Linux_20_157380.tar.gz')
    else
      Chef::Log.warn 'Unsupported Insights for ArcGIS version'
    end
  end
end
