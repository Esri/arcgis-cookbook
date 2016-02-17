#
# Cookbook Name:: arcgis
# Resource:: server
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

actions :system, :install, :uninstall, :authorize, :create_site, :join_site, :join_cluster, :configure_https, :register_database, :federate

attribute :setup, :kind_of => String
attribute :product_code, :kind_of => String
attribute :install_dir, :kind_of => String
attribute :python_dir, :kind_of => String
attribute :run_as_user, :kind_of => String
attribute :run_as_password, :kind_of => String
attribute :server_url, :kind_of => String
attribute :server_local_url, :kind_of => String
attribute :primary_server_url, :kind_of => String
attribute :keystore_file, :kind_of => String
attribute :keystore_password, :kind_of => String
attribute :cert_alias, :kind_of => String
attribute :cluster, :kind_of => String
attribute :server_id, :kind_of => String
attribute :secret_key, :kind_of => String
attribute :portal_url, :kind_of => String
attribute :portal_username, :kind_of => String
attribute :portal_password, :kind_of => String
attribute :username, :kind_of => String
attribute :password, :kind_of => String
attribute :server_directories_root, :kind_of => String
attribute :config_store_connection_string, :kind_of => String 
attribute :config_store_connection_secret, :kind_of => String
attribute :config_store_type, :kind_of => String
attribute :authorization_file, :kind_of => String
attribute :authorization_file_version, :kind_of => String
attribute :data_item_path, :kind_of => String
attribute :connection_string, :kind_of => String
attribute :is_managed, :kind_of => [TrueClass, FalseClass], :default => false
attribute :system_properties, :kind_of => Hash, :default => {}

def initialize(*args)
  super
  @action = :install
end
