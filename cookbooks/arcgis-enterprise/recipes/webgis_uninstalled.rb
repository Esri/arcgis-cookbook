#
# Cookbook Name:: arcgis-enterprise
# Recipe:: all_uninstalled
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

arcgis_enterprise_webadaptor 'Uninstall Web Adaptor for Portal' do
  install_dir node['arcgis']['web_adaptor']['install_dir']
  product_code node['arcgis']['web_adaptor']['product_code2']
  instance_name node['arcgis']['portal']['wa_name']
  if node['platform'] == 'windows'
    only_if { 
      !Utils.wa_product_code(node['arcgis']['portal']['wa_name'],
                            [node['arcgis']['web_adaptor']['product_code'],
                             node['arcgis']['web_adaptor']['product_code2']]).nil?
    }
  else
    only_if {
      ::File.exist?(::File.join(node['arcgis']['web_server']['webapp_dir'],
                                node['arcgis']['portal']['wa_name'] + '.war'))
    }
  end
  action :uninstall
end

arcgis_enterprise_webadaptor 'Uninstall Web Adaptor for Server' do
  install_dir node['arcgis']['web_adaptor']['install_dir']
  product_code node['arcgis']['web_adaptor']['product_code']
  instance_name node['arcgis']['server']['wa_name']
  if node['platform'] == 'windows'
    only_if {
      !Utils.wa_product_code(node['arcgis']['server']['wa_name'],
                            [node['arcgis']['web_adaptor']['product_code'],
                             node['arcgis']['web_adaptor']['product_code2']]).nil?
    }
  else
    only_if {
      ::File.exist?(::File.join(node['arcgis']['web_server']['webapp_dir'],
                                node['arcgis']['server']['wa_name'] + '.war'))
    }
  end
  action :uninstall
end

arcgis_enterprise_portal 'Uninstall Portal for ArcGIS' do
  install_dir node['arcgis']['portal']['install_dir']
  product_code node['arcgis']['portal']['product_code']
  if node['platform'] == 'windows'
    only_if {
      Utils.product_installed?(node['arcgis']['portal']['product_code'])
    }
  else
    only_if {
      ::File.exist?(::File.join(node['arcgis']['portal']['install_dir'],
                                node['arcgis']['portal']['install_subdir'],
                                'startportal.sh'))
    }
  end
  action :uninstall
end

arcgis_enterprise_datastore 'Uninstall ArcGIS DataStore' do
  install_dir node['arcgis']['data_store']['install_dir']
  product_code node['arcgis']['data_store']['product_code']
  if node['platform'] == 'windows'
    only_if {
      Utils.product_installed?(node['arcgis']['data_store']['product_code'])
    }
  else
    only_if {
      ::File.exist?(::File.join(node['arcgis']['data_store']['install_dir'],
                                node['arcgis']['data_store']['install_subdir'],
                                'startdatastore.sh'))
    }
  end
  action :uninstall
end

arcgis_enterprise_server 'Uninstall ArcGIS Server' do
  install_dir node['arcgis']['server']['install_dir']
  product_code node['arcgis']['server']['product_code']
  if node['platform'] == 'windows'
    only_if {
      Utils.product_installed?(node['arcgis']['server']['product_code'])
    }
  else
    only_if {
      ::File.exist?(::File.join(node['arcgis']['server']['install_dir'],
                                node['arcgis']['server']['install_subdir'],
                                'startserver.sh'))
    }
  end
  action [:stop, :uninstall]
end
