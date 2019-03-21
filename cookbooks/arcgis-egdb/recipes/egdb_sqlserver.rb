#
# Cookbook Name:: arcgis-egdb
# Recipe:: egdb_sqlserver
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

# Create scripts for SQL Server EGDB configuration

template ::File.join(node['arcgis']['misc']['scripts_dir'],
                     'RDS_Creation.ps1') do
  source 'RDS_Creation.ps1.erb'
  cookbook 'arcgis-egdb'
  variables ({
    scripts_dir: node['arcgis']['misc']['scripts_dir'],
    logs_dir: node['arcgis']['misc']['scripts_dir'],
    keycodes: node['arcgis']['egdb']['keycodes'],
    pythonpath: node['arcgis']['python']['runtime_environment']
  })
end

template ::File.join(node['arcgis']['misc']['scripts_dir'],
                     'RDS_create_egdb_geodata.sql') do
  source 'RDS_create_egdb_geodata.sql.erb'
  cookbook 'arcgis-egdb'
  variables ({
    master_username: node['arcgis']['egdb']['master_username'],
    data_items: node['arcgis']['egdb']['data_items']
  })
end

template ::File.join(node['arcgis']['misc']['scripts_dir'],
                     'RDS_create_sde_login_user.sql') do
  source 'RDS_create_sde_login_user.sql.erb'
  cookbook 'arcgis-egdb'
  variables ({
    db_username: node['arcgis']['egdb']['db_username'],
    data_items: node['arcgis']['egdb']['data_items']
  })
end

template ::File.join(node['arcgis']['misc']['scripts_dir'],
                     'RDS_enable_enterprise_egdb_geodata.py') do
  source 'RDS_enable_enterprise_egdb_geodata.py.erb'
  cookbook 'arcgis-egdb'
  variables ({
    data_items: node['arcgis']['egdb']['data_items']
  })
end

template ::File.join(node['arcgis']['misc']['scripts_dir'],
                     'RDS_create_connection_files.py') do
  source 'RDS_create_connection_files.py.erb'
  cookbook 'arcgis-egdb'
  variables ({
    data_items: node['arcgis']['egdb']['data_items']
  })
end

execute 'Create EGDB in SQL Server' do
  command ['PowerShell.exe', '-file',
           "\"#{::File.join(node['arcgis']['misc']['scripts_dir'],
                            'RDS_Creation.ps1')}\"",
           node['arcgis']['egdb']['master_username'],
           node['arcgis']['egdb']['master_password'],
           node['arcgis']['egdb']['db_username'],
           node['arcgis']['egdb']['db_password']].join(' ')
  only_if do
    !node['arcgis']['egdb']['endpoint'].nil? &&
      !node['arcgis']['egdb']['endpoint'].empty? &&
      !::File.exist?(node['arcgis']['egdb']['data_items'][0]['connection_file'])
  end
end
