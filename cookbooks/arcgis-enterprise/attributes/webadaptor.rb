#
# Cookbook Name:: arcgis-enterprise
# Attributes:: webadaptor
#
# Copyright 2015 Esri
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

default['arcgis']['web_adaptor'].tap do |web_adaptor|

  web_adaptor['admin_access'] = false
  web_adaptor['install_system_requirements'] = true

  case node['platform']
  when 'windows'
    web_adaptor['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                       'ArcGIS ' + node['arcgis']['version'],
                                       'WebAdaptorIIS', 'Setup.exe')
    web_adaptor['lp-setup'] = node['arcgis']['web_adaptor']['setup']
    web_adaptor['install_dir'] = ''

    case node['arcgis']['version']
    when '10.6'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'Web_Adaptor_for_Microsoft_IIS_106_161833.exe')
      web_adaptor['product_code'] = '{4FB9D475-9A23-478D-B9F7-05EBA2073FC7}'
      web_adaptor['product_code2'] = '{38DBD944-7F0E-48EB-9DCB-98A0567FB062}'
    when '10.5.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'Web_Adaptor_for_Microsoft_IIS_1051_156367.exe')
      web_adaptor['product_code'] = '{0A9DA130-E764-485F-8C1A-AD78B04AA7A4}'
      web_adaptor['product_code2'] = '{B8A6A873-ED78-47CE-A9B4-AB3192C47604}'
    when '10.5'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'Web_Adaptor_for_Microsoft_IIS_105_154007.exe')
      web_adaptor['product_code'] = '{87B4BD93-A5E5-469E-9224-8A289C6B2F10}'
      web_adaptor['product_code2'] = '{604CF558-B7E1-4271-8543-75E260080DFA}'
    when '10.4.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'Web_Adaptor_for_Microsoft_IIS_1041_151933.exe')
      web_adaptor['product_code'] = '{F53FEE2B-54DD-4A6F-8545-6865F4FBF6DC}'
      web_adaptor['product_code2'] = '{475ACDE5-D140-4F10-9006-C804CA93D2EF}'
    when '10.4'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'Web_Adaptor_for_Microsoft_IIS_104_149435.exe')
      web_adaptor['product_code'] = '{B83D9E06-B57C-4B26-BF7A-004BE10AB2D5}'
      web_adaptor['product_code2'] = '{E2C783F3-6F85-4B49-BFCD-6D6A57A2CFCE}'
    else
      throw 'Unsupported ArcGIS version'
    end

    web_adaptor['product_codes'] = ['{B83D9E06-B57C-4B26-BF7A-004BE10AB2D5}',
                                    '{E2C783F3-6F85-4B49-BFCD-6D6A57A2CFCE}',
                                    '{F53FEE2B-54DD-4A6F-8545-6865F4FBF6DC}',
                                    '{475ACDE5-D140-4F10-9006-C804CA93D2EF}',
                                    '{87B4BD93-A5E5-469E-9224-8A289C6B2F10}',
                                    '{604CF558-B7E1-4271-8543-75E260080DFA}',
                                    '{0A9DA130-E764-485F-8C1A-AD78B04AA7A4}',
                                    '{B8A6A873-ED78-47CE-A9B4-AB3192C47604}',
                                    '{4FB9D475-9A23-478D-B9F7-05EBA2073FC7}',
                                    '{38DBD944-7F0E-48EB-9DCB-98A0567FB062}']
  else # node['platform'] == 'linux'
    web_adaptor['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                       node['arcgis']['version'],
                                       'WebAdaptor', 'Setup')
    web_adaptor['lp-setup'] = node['arcgis']['web_adaptor']['setup']

    case node['arcgis']['version']
    when '10.6'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_Java_Linux_106_161911.tar.gz')
    when '10.5.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_Java_Linux_1051_156442.tar.gz')
    when '10.5'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_Java_Linux_105_154055.tar.gz')
    when '10.4.1'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_Java_Linux_1041_152000.tar.gz')
    when '10.4'
      web_adaptor['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                                 'Web_Adaptor_Java_Linux_104_149448.tar.gz')
    else
      throw 'Unsupported ArcGIS version'
    end

    web_adaptor['install_dir'] = '/'
    web_adaptor['install_subdir'] = 'arcgis/webadaptor' + node['arcgis']['version']
  end

end
