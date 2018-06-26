#
# Cookbook Name:: arcgis-enterprise
# Resource:: portal_authentication
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

actions :disable_signup, :use_windows_users, :disable_iis_anonymous_authentication,
        :enable_iis_windows_authentication, :add_iis_ie11_compatibility_header

attribute :portal_url, :kind_of => String
attribute :wa_name, :kind_of => String
attribute :username, :kind_of => String
attribute :password, :kind_of => String
attribute :active_directory_username, :kind_of => String
attribute :active_directory_password, :kind_of => String

def initialize(*args)
  super
  @action = :install
end
