#
# Cookbook Name:: arcgis-desktop
# Resource:: desktop
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

actions :system, :install, :uninstall, :authorize

attribute :setup, :kind_of => String
attribute :product_code, :kind_of => String
attribute :install_dir, :kind_of => String
attribute :python_dir, :kind_of => String
attribute :install_features, :kind_of => String
attribute :authorization_file, :kind_of => String
attribute :authorization_file_version, :kind_of => String
attribute :esri_license_host, :kind_of => String
attribute :software_class, :kind_of => String
attribute :seat_preference, :kind_of => String
attribute :desktop_config, :kind_of => [TrueClass, FalseClass], :default => false
attribute :modifyflexdacl, :kind_of => [TrueClass, FalseClass], :default => false

def initialize(*args)
  super
  @action = :install
end
