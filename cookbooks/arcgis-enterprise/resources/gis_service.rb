#
# Cookbook Name:: arcgis-enterprise
# Resource:: gis_service
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

actions :publish, :start, :stop, :delete

attribute :server_url, :kind_of => String
attribute :username, :kind_of => String
attribute :password, :kind_of => String
attribute :folder, :kind_of => String
attribute :name, :kind_of => String
attribute :type, :kind_of => String
attribute :definition_file, :kind_of => String
attribute :properties, :kind_of => Hash, :default => {}

def initialize(*args)
  super
  @action = :publish
end
