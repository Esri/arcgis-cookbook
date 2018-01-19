#
# Cookbook Name:: arcgis-enterprise
# Recipe:: rds_egdb
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

if node['platform'] == 'windows'
  connection_files = ::File.join(node['arcgis']['server']['install_dir'], 'framework', 'etc')
else
  connection_files = '/tmp'
end

data_items = [{
  'data_item_path' => '/enterpriseDatabases/managedDatabase',
  'connection_file' => ::File.join(connection_files, 'RDS_egdb.sde'),
  'is_managed' => true
}, {
  'data_item_path' => '/namedWorkspaces/replicatedDatabase',
  'connection_file' => ::File.join(connection_files, 'RDS_geodata.sde'),
  'is_managed' => false
}]

ruby_block 'Copy license' do
  block do
    if node['platform'] == 'windows'
      FileUtils.cp('C:\\Program Files\\ESRI\\License' +
                   node['arcgis']['server']['authorization_file_version'] + '\\sysgen\\keycodes',
                   ::File.join(node['arcgis']['server']['install_dir'], 'framework\\etc\\license.ecp'))
    else
      license_ecp = ::File.join(node['arcgis']['server']['install_dir'], 
                                node['arcgis']['server']['install_subdir'],
                                'framework/etc/license.ecp')
      FileUtils.cp(::File.join(node['arcgis']['server']['install_dir'], 
                               node['arcgis']['server']['install_subdir'], 
                               'framework/runtime/.wine/drive_c/Program Files/ESRI/License' +
                               node['arcgis']['server']['authorization_file_version'] + '/sysgen/keycodes'),
                   license_ecp)
      FileUtils.chown(node['arcgis']['run_as_user'], node['arcgis']['run_as_user'], license_ecp)
    end
  end
  only_if { !node['arcgis']['rds']['endpoint'].nil? &&
            !node['arcgis']['rds']['endpoint'].empty? }
end

execute 'Create EGDB in SQL Server RDS' do
  command ['PowerShell.exe', '-file',
           "\"#{::File.join(node['arcgis']['server']['install_dir'],
                            'framework\\etc\RDS_Creation.ps1')}\"",
           node['arcgis']['rds']['username'],
           node['arcgis']['rds']['password']].join(' ')
  only_if { node['arcgis']['rds']['engine'] == 'sqlserver-se' &&
           !node['arcgis']['rds']['endpoint'].nil? &&
           !node['arcgis']['rds']['endpoint'].empty? &&
           !::File.exists?(data_items[0]['connection_file'])}
end

execute 'Create EGDB in PostgreSQL RDS' do
  if node['platform'] == 'windows'
    command ["\"#{::File.join(node['arcgis']['server']['install_dir'],
                              'framework\\etc\\RDS_postgres.bat')}\"",
             node['arcgis']['rds']['endpoint'],
             node['arcgis']['rds']['username'],
             node['arcgis']['rds']['password']].join(' ')
  else
    command ['sudo su - arcgis', ::File.join(node['arcgis']['server']['install_dir'],
                                    node['arcgis']['server']['install_subdir'],
                                    'framework/etc/RDS_postgres.sh'),
             node['arcgis']['rds']['endpoint'],
             node['arcgis']['rds']['username'],
             node['arcgis']['rds']['password']].join(' ')
  end
  only_if { node['arcgis']['rds']['engine'] == 'postgres' &&
           !node['arcgis']['rds']['endpoint'].nil? &&
           !node['arcgis']['rds']['endpoint'].empty? &&
           !::File.exists?(data_items[0]['connection_file']) }
end

ruby_block 'Register RDS EGDB' do
  block do
    admin_client = ArcGIS::ServerAdminClient.new(node['arcgis']['server']['private_url'],
                                                 node['arcgis']['server']['admin_username'],
                                                 node['arcgis']['server']['admin_password'])

    rest_client = ArcGIS::ServerRestClient.new(node['arcgis']['server']['private_url'],
                                               node['arcgis']['server']['admin_username'],
                                               node['arcgis']['server']['admin_password'])

    generate_token_url = admin_client.info['authInfo']['tokenServicesUrl']

    if !generate_token_url.nil? && !generate_token_url.empty?
      admin_client.generate_token_url = generate_token_url
    end

    data_items.each do |item|
      item_id = admin_client.upload_item(item['connection_file'], "EGDB connection file.")

      connection_string = rest_client.get_database_connection_string(item_id)

      admin_client.register_database(item['data_item_path'], connection_string, item['is_managed'])
    end
  end
  subscribes :run, "execute[Create EGDB in SQL Server RDS]", :immediately
  subscribes :run, "execute[Create EGDB in PostgreSQL RDS]", :immediately
  action :nothing
end
