#
# Cookbook Name:: arcgis-enterprise
# Recipe:: portal_wa
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
#

arcgis_enterprise_webadaptor 'Unpack ArcGIS Web Adaptor' do
  setup_archive node['arcgis']['web_adaptor']['setup_archive']
  setups_repo node['arcgis']['repository']['setups']
  run_as_user node['arcgis']['run_as_user']
  only_if { ::File.exist?(node['arcgis']['web_adaptor']['setup_archive']) &&
            !::File.exist?(node['arcgis']['web_adaptor']['setup']) }
  if node['platform'] == 'windows'
    not_if { !Utils.wa_product_code(node['arcgis']['server']['wa_name'],
                                    [node['arcgis']['web_adaptor']['product_code'],
                                     node['arcgis']['web_adaptor']['product_code2']]).nil? }
  else
    not_if { ::File.exist?(::File.join(node['arcgis']['web_adaptor']['install_dir'],
                                       node['arcgis']['web_adaptor']['install_subdir'],
                                      'java/arcgis.war')) }
  end
  action :unpack
end

arcgis_enterprise_webadaptor 'Install Web Adaptor for Portal' do
  install_dir node['arcgis']['web_adaptor']['install_dir']
  setup node['arcgis']['web_adaptor']['setup']
  run_as_user node['arcgis']['run_as_user']
  instance_name node['arcgis']['portal']['wa_name']
  if node['platform'] == 'windows'
    not_if { !Utils.wa_product_code(node['arcgis']['portal']['wa_name'],
                                    [node['arcgis']['web_adaptor']['product_code'],
                                     node['arcgis']['web_adaptor']['product_code2']]).nil? }
  else
    not_if { ::File.exist?(::File.join(node['arcgis']['web_adaptor']['install_dir'],
                                       node['arcgis']['web_adaptor']['install_subdir'],
                                      'java/arcgis.war')) }
  end
  action :install
end

arcgis_enterprise_webadaptor 'Deploy Web Adaptor for Portal' do
  install_dir node['arcgis']['web_adaptor']['install_dir']
  instance_name node['arcgis']['portal']['wa_name']
  not_if { node['platform'] == 'windows' }
  action :deploy
end

arcgis_enterprise_webadaptor 'Configure Web Adaptor with Portal' do
  portal_wa_url node['arcgis']['portal']['wa_url']
  portal_url node['arcgis']['portal']['url']
  install_dir node['arcgis']['web_adaptor']['install_dir']
  instance_name node['arcgis']['portal']['wa_name']
  username node['arcgis']['portal']['admin_username']
  password node['arcgis']['portal']['admin_password']
  retries 5
  retry_delay 60
  action :configure_with_portal
end
