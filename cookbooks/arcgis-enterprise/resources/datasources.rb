#
# Cookbook Name:: arcgis-enterprise
# Resource:: datasources
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
#

actions :create_ags_connection_file, :delete_ags_connection_file,
        :create_folder, :share_folder, :register_folder,
        :register_sde_files, :register_sde_files_from_folder

attribute :admin_user, :kind_of => String
attribute :admin_password, :kind_of => String
attribute :folder, :kind_of => Hash
attribute :authorize_arcgis_service_account, :kind_of => [TrueClass, FalseClass], :default => false
attribute :publish_with_alternative_path, :kind_of => [TrueClass, FalseClass], :default => false
attribute :publish_with_fqdn, :kind_of => [TrueClass, FalseClass], :default => false
attribute :publish_with_hostname, :kind_of => [TrueClass, FalseClass], :default => false
        
def initialize(*args)
  super
  @action = :publish
end
