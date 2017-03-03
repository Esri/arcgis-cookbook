#
# Cookbook Name:: esri-iis
# Resource:: iis
#
# Copyright 2017 Esri
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

actions :configure_https

attribute :keystore_file, :kind_of => String
attribute :keystore_password, :kind_of => String
attribute :web_site, :kind_of => String, :default => 'Default Web Site'
attribute :replace_https_binding, :kind_of => [TrueClass, FalseClass], :default => false

def initialize(*args)
  super
  @action = :configure_https
end
