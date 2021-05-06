#
# Cookbook Name:: arcgis-enterprise
# Attributes:: fileserver
#
# Copyright 2018 Esri
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
include_attribute 'arcgis-enterprise::server'
include_attribute 'arcgis-enterprise::datastore'
include_attribute 'arcgis-enterprise::portal'


default['arcgis']['fileserver']['shares'] = [ node['arcgis']['server']['local_directories_root'],
                                              node['arcgis']['data_store']['local_backup_dir'],
                                              ::File.expand_path("..", node['arcgis']['portal']['local_content_dir']) ]

default['arcgis']['fileserver']['directories'] = [ node['arcgis']['server']['local_directories_root'],
                                                   node['arcgis']['data_store']['local_backup_dir'],
                                                   ::File.join(node['arcgis']['data_store']['local_backup_dir'], 'tilecache'),
                                                   ::File.join(node['arcgis']['data_store']['local_backup_dir'], 'relational'),
                                                   ::File.expand_path("..", node['arcgis']['portal']['local_content_dir']),
                                                   node['arcgis']['portal']['local_content_dir']]
