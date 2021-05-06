#
# Cookbook Name:: arcgis-egdb
# Recipe:: register_egdb
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
#

# Register EGDBs created by egdb_postgres or egdb_sqlserver recipes with ArcGIS Server.

ruby_block 'Register RDS EGDB' do
  block do
    admin_client = ArcGIS::ServerAdminClient.new(node['arcgis']['server']['url'],
                                                 node['arcgis']['server']['admin_username'],
                                                 node['arcgis']['server']['admin_password'])

    rest_client = ArcGIS::ServerRestClient.new(node['arcgis']['server']['url'],
                                               node['arcgis']['server']['admin_username'],
                                               node['arcgis']['server']['admin_password'])

    generate_token_url = admin_client.info['authInfo']['tokenServicesUrl']

    if !generate_token_url.nil? && !generate_token_url.empty?
      admin_client.generate_token_url = generate_token_url
    end

    node['arcgis']['egdb']['data_items'].each do |item|
      item_id = admin_client.upload_item(item['connection_file'], 'EGDB connection file.')

      connection_string = rest_client.get_database_connection_string(item_id)

      admin_client.register_database(item['data_item_path'], connection_string, item['is_managed'], item['connection_type'])
    end
  end
  subscribes :run, 'execute[Create EGDB in SQL Server]', :immediately
  subscribes :run, 'execute[Create EGDB in PostgreSQL]', :immediately
  action :nothing
end
