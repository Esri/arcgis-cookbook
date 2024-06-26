#
# Cookbook Name:: arcgis-pro
# Resource:: pro
#
# Copyright 2015-2024 Esri
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

unified_mode true

actions :system, :unpack, :install, :uninstall, :patches, :authorize

attribute :setup_archive, kind_of: String
attribute :setups_repo, kind_of: String
attribute :setup, kind_of: String
attribute :product_code, kind_of: String
attribute :install_dir, kind_of: String
attribute :software_class, kind_of: String
attribute :esri_license_host, kind_of: String
attribute :authorization_type, kind_of: String
attribute :authorization_file, kind_of: String
attribute :authorization_file_version, kind_of: String
attribute :portal_list, kind_of: String
attribute :allusers, kind_of: Integer

def initialize(*args)
  super
  @action = :install
end
