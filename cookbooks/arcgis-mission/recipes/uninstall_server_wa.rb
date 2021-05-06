#
# Cookbook Name:: arcgis-mission
# Recipe:: uninstall_server_wa
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
#

arcgis_enterprise_webadaptor 'Uninstall Web Adaptor for Mission Server' do
  install_dir node['arcgis']['web_adaptor']['install_dir']
  instance_name node['arcgis']['mission_server']['wa_name']
  run_as_user node['arcgis']['run_as_user']
  if node['platform'] == 'windows'
    product_code Utils.wa_product_code(node['arcgis']['mission_server']['wa_name'],
                                      [node['arcgis']['web_adaptor']['product_code'],
                                       node['arcgis']['web_adaptor']['product_code2']])
    only_if {
      !Utils.wa_product_code(node['arcgis']['mission_server']['wa_name'],
                            [node['arcgis']['web_adaptor']['product_code'],
                             node['arcgis']['web_adaptor']['product_code2']]).nil?
    }
  else
    only_if {
      ::File.exist?(::File.join(node['arcgis']['web_server']['webapp_dir'],
                                node['arcgis']['mission_server']['wa_name'] + '.war'))
    }
  end
  action :uninstall
end
