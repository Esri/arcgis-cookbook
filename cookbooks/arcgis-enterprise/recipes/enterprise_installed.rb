#
# Cookbook Name:: arcgis-enterprise
# Recipe:: enterprise_installed
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
#

arcgis_enterprise_server 'Install ArcGIS Server' do
  setup node['arcgis']['server']['setup']
  install_dir node['arcgis']['server']['install_dir']
  product_code node['arcgis']['server']['product_code']
  python_dir node['arcgis']['python']['install_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['server']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                               node['hostname'],
                                               node['arcgis']['version'],
                                               :ArcGISServer) }
    notifies :configure_autostart, 'arcgis_enterprise_server[Configure arcgisserver service]', :immediately
  end
  action [:system, :install]
end

arcgis_enterprise_datastore 'Install ArcGIS DataStore' do
  setup node['arcgis']['data_store']['setup']
  install_dir node['arcgis']['data_store']['install_dir']
  product_code node['arcgis']['data_store']['product_code']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  if node['platform'] == 'windows'
    not_if { Utils.product_installed?(node['arcgis']['data_store']['product_code']) }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                               node['hostname'],
                                               node['arcgis']['version'],
                                               :ArcGISDataStore) }
    notifies :configure_autostart, 'arcgis_enterprise_datastore[Configure arcgisdatastore service]', :immediately
  end
  action [:system, :install]
end

arcgis_enterprise_portal 'Install Portal for ArcGIS' do
  install_dir node['arcgis']['portal']['install_dir']
  setup node['arcgis']['portal']['setup']
  product_code node['arcgis']['portal']['product_code']
  content_dir node['arcgis']['portal']['content_dir']
  run_as_user node['arcgis']['run_as_user']
  run_as_password node['arcgis']['run_as_password']
  if node['platform'] == 'windows'
    not_if {
      Utils.product_installed?(node['arcgis']['portal']['product_code'])
    }
  else
    not_if { EsriProperties.product_installed?(node['arcgis']['run_as_user'],
                                               node['hostname'],
                                               node['arcgis']['version'],
                                               :ArcGISPortal) }
    notifies :configure_autostart, 'arcgis_enterprise_portal[Configure arcgisportal service]', :immediately
  end
  action [:system, :install]
end

arcgis_enterprise_webadaptor 'Install Web Adaptor for Server' do
  install_dir node['arcgis']['web_adaptor']['install_dir']
  setup node['arcgis']['web_adaptor']['setup']
  product_code node['arcgis']['web_adaptor']['product_code']
  instance_name node['arcgis']['server']['wa_name']
  if node['platform'] == 'windows'
    not_if { 
      !Utils.wa_product_code(node['arcgis']['server']['wa_name'],
                            [node['arcgis']['web_adaptor']['product_code'],
                             node['arcgis']['web_adaptor']['product_code2']]).nil?
    }
  else
    not_if {
      ::File.exist?(::File.join(node['arcgis']['web_server']['webapp_dir'],
                                node['arcgis']['server']['wa_name'] + '.war'))
    }
  end
  action :install
end

arcgis_enterprise_webadaptor 'Install Web Adaptor for Portal' do
  install_dir node['arcgis']['web_adaptor']['install_dir']
  setup node['arcgis']['web_adaptor']['setup']
  product_code node['arcgis']['web_adaptor']['product_code2']
  instance_name node['arcgis']['portal']['wa_name']
  if node['platform'] == 'windows'
    not_if { 
      !Utils.wa_product_code(node['arcgis']['portal']['wa_name'],
                            [node['arcgis']['web_adaptor']['product_code'],
                             node['arcgis']['web_adaptor']['product_code2']]).nil?
    }
  else
    not_if {
      ::File.exist?(::File.join(node['arcgis']['web_server']['webapp_dir'],
                                node['arcgis']['portal']['wa_name'] + '.war'))
    }
  end
  action :install
end
