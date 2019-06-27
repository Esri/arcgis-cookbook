#
# Cookbook Name:: arcgis-enterprise
# Attributes:: webstyles
#
# Copyright 2019 Esri
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
    when '10.7.1'
      webstyles['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                               'ArcGIS_Web_Styles_Windows_1071_170272.exe').tr('/', '\\')
      webstyles['product_code'] = '{B2E42A8D-1EE9-4610-9932-D0FCFD06D2AF}'
    else
      Chef::Log.warn 'Unsupported ArcGIS Web Styles version'
    end
  else # node['platform'] == 'linux'
    webstyles['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                     node['arcgis']['version'],
                                     'WebStyles', 'WebStyles-Setup.sh')

    case node['arcgis']['version']
    when '10.7.1'
      webstyles['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                               'ArcGIS_Web_Styles_Linux_1071_170273.tar.gz')
    else
      Chef::Log.warn 'Unsupported ArcGIS Web Styles version'
    end
  end
end
