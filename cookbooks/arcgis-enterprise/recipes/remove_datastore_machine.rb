#
# Cookbook Name:: arcgis-enterprise
# Recipe:: remove_datastore_machine
#
# Copyright 2020 Esri
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

arcgis_enterprise_datastore 'Remove Data Store Machine' do
  install_dir node['arcgis']['data_store']['install_dir']
  types node['arcgis']['data_store']['types']
  preferredidentifier node['arcgis']['data_store']['preferredidentifier']
  hostidentifier node['arcgis']['data_store']['hostidentifier']
  run_as_user node['arcgis']['run_as_user']
  force_remove_machine node['arcgis']['data_store']['force_remove_machine']
  action :remove_machine
end
