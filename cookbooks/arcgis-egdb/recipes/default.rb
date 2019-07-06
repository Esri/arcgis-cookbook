#
# Cookbook Name:: arcgis-egdb
# Recipe:: rds_egdb
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

directory node['arcgis']['misc']['scripts_dir'] do
  mode '0755' if node['platform'] != 'windows'
  recursive true
  action :create
end

directory node['arcgis']['egdb']['connection_files_dir'] do
  owner node['arcgis']['run_as_user']
  mode '0755' if node['platform'] != 'windows'
  recursive true
  action :create
end

db_engine = node['arcgis']['egdb']['engine']
include_recipe 'arcgis-egdb::egdb_sqlserver' if db_engine == 'sqlserver-se'
include_recipe 'arcgis-egdb::egdb_postgres' if db_engine == 'postgres'
include_recipe 'arcgis-egdb::register_egdb'
