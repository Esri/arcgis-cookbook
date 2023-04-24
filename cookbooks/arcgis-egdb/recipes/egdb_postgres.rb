#
# Cookbook Name:: arcgis-egdb
# Recipe:: egdb_postgres
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

# Create scripts for EGDB configuration in PostgreSQL

template ::File.join(node['arcgis']['misc']['scripts_dir'],
                     'RDS_postgres.bat') do
  source 'RDS_postgres.bat.erb'
  cookbook 'arcgis-egdb'
  variables ({
    scripts_dir: node['arcgis']['misc']['scripts_dir'],
    postgres_bin: node['arcgis']['egdb']['postgresbin'],
    keycodes: node['arcgis']['egdb']['keycodes'],
    pythonpath: node['arcgis']['python']['runtime_environment'],
    data_items: node['arcgis']['egdb']['data_items']
  })
  only_if { node['platform'] == 'windows' }
end

template ::File.join(node['arcgis']['misc']['scripts_dir'],
                     'RDS_postgres.sh') do
  source 'RDS_postgres.sh.erb'
  mode '0755'
  cookbook 'arcgis-egdb'
  variables ({
    scripts_dir: node['arcgis']['misc']['scripts_dir'],
    postgres_bin: node['arcgis']['egdb']['postgresbin'],
    keycodes: node['arcgis']['egdb']['keycodes'],
    pythonpath: node['arcgis']['python']['runtime_environment'],
    data_items: node['arcgis']['egdb']['data_items']
  })
  only_if { node['platform'] != 'windows' }
end

template ::File.join(node['arcgis']['misc']['scripts_dir'],
                     'create_sde_schema_install_postgis.sql') do
  source 'create_sde_schema_install_postgis.sql.erb'
  cookbook 'arcgis-egdb'
  variables ({
    db_username: node['arcgis']['egdb']['db_username']
  })
end

template ::File.join(node['arcgis']['misc']['scripts_dir'],
                     'enable_enterprise_gdb.py') do
  source 'enable_enterprise_gdb.py.erb'
  cookbook 'arcgis-egdb'
  variables ({
    connection_files_dir: node['arcgis']['egdb']['connection_files_dir']
  })
end

execute 'Create EGDB in PostgreSQL' do
  cwd node['arcgis']['misc']['scripts_dir']
  live_stream true
  sensitive true
  if node['platform'] == 'windows'
    command [::File.join(node['arcgis']['misc']['scripts_dir'],'RDS_postgres.bat'),
             node['arcgis']['egdb']['endpoint'],
             node['arcgis']['egdb']['master_username'],
             node['arcgis']['egdb']['master_password'],
             node['arcgis']['egdb']['db_username'],
             node['arcgis']['egdb']['db_password']].join(' ')
  else
    command ["sudo su - #{node['arcgis']['run_as_user']}",
             ::File.join(node['arcgis']['misc']['scripts_dir'], 'RDS_postgres.sh'),
             node['arcgis']['egdb']['endpoint'],
             node['arcgis']['egdb']['master_username'],
             node['arcgis']['egdb']['master_password'],
             node['arcgis']['egdb']['db_username'],
             node['arcgis']['egdb']['db_password']].join(' ')
  end
  only_if do
    !node['arcgis']['egdb']['endpoint'].nil? &&
      !node['arcgis']['egdb']['endpoint'].empty? &&
      !::File.exist?(node['arcgis']['egdb']['data_items'][0]['connection_file'])
  end
end
