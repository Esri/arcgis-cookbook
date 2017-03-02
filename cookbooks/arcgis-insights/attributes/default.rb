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

include_attribute 'arcgis-enterprise'

default['arcgis']['insights']['version'] = '1.0'

case node['platform']
when 'windows'
  default['arcgis']['insights']['setup'] = node['arcgis']['repository']['setups'] + '\\Insights ' +
                                           node['arcgis']['insights']['version'] + '\\Insights\\Setup.exe'

  case node['arcgis']['insights']['version']
  when '1.1'
    default['arcgis']['insights']['product_code'] = '{7C00C004-6379-4B0C-856A-987A7A43CD71}'
    default['arcgis']['insights']['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                                 'Insights_for_ArcGIS_Windows_11_155241.exe')
  when '1.0'
    default['arcgis']['insights']['product_code'] = '{DA27EEE3-FB34-4092-8A07-38EEEFF0DFF5}'
    default['arcgis']['insights']['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                                 'Insights_for_ArcGIS_Windows_10_154047.exe')
  else
    throw 'Unsupported Insight for ArcGIS version'
  end
else # node['platform'] == 'linux'
  default['arcgis']['insights']['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                                       node['arcgis']['insights']['version'],
                                                       'Insights/Insights-Setup.sh')

  case node['arcgis']['insights']['version']
  when '1.1'
    default['arcgis']['insights']['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                                 'Insights_for_ArcGIS_Linux_11_155242.tar.gz')
  when '1.0'
    default['arcgis']['insights']['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                                 'Insights_for_ArcGIS_Linux_10_154060.tar.gz')
  else
    throw 'Unsupported Insight for ArcGIS version'
  end
end
