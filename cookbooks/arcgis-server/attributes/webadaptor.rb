#
# Cookbook Name:: arcgis-server
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
    web_adaptor['setup'] = 'C:\\Temp\\WebAdaptorIIS\\Setup.exe'
    web_adaptor['lp-setup'] = 'C:\\Temp\\WebAdaptorIIS\\SetupFile\\Setup.msi'
    web_adaptor['install_dir'] = ''

    case node['arcgis']['version']
    when '10.5'
      web_adaptor['product_code'] = '{87B4BD93-A5E5-469E-9224-8A289C6B2F10}'
      web_adaptor['product_code2'] = '{604CF558-B7E1-4271-8543-75E260080DFA}'
    when '10.4.1'
      web_adaptor['product_code'] = '{F53FEE2B-54DD-4A6F-8545-6865F4FBF6DC}'
      web_adaptor['product_code2'] = '{475ACDE5-D140-4F10-9006-C804CA93D2EF}'
    when '10.4'
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
                                    '{604CF558-B7E1-4271-8543-75E260080DFA}']
  else # node['platform'] == 'linux'
    web_adaptor['setup'] = '/tmp/web-adaptor-cd/Setup'
    web_adaptor['install_dir'] = '/'
    web_adaptor['install_subdir'] = 'arcgis/webadaptor' + node['arcgis']['version']
  end

end
