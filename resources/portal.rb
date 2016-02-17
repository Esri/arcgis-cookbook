#
# Cookbook Name:: arcgis
# Resource:: portal
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

actions :system, :install, :uninstall, :authorize, :create_site, :join_site, :configure_https, :register_server, :federate_server, :stop, :start

attribute :setup, :kind_of => String
attribute :product_code, :kind_of => String
attribute :install_dir, :kind_of => String
attribute :data_dir, :kind_of => String
attribute :content_dir, :kind_of => String
attribute :run_as_user, :kind_of => String
attribute :run_as_password, :kind_of => String
attribute :authorization_file, :kind_of => String
attribute :authorization_file_version, :kind_of => String
attribute :portal_url, :kind_of => String
attribute :portal_local_url, :kind_of => String
attribute :portal_private_url, :kind_of => String
attribute :primary_machine_url, :kind_of => String
attribute :web_context_url, :kind_of => String
attribute :keystore_file, :kind_of => String
attribute :keystore_password, :kind_of => String
attribute :cert_alias, :kind_of => String
attribute :username, :kind_of => String
attribute :password, :kind_of => String
attribute :email, :kind_of => String
attribute :full_name, :kind_of => String
attribute :description, :kind_of => String
attribute :security_question, :kind_of => String
attribute :security_question_answer, :kind_of => String
attribute :server_url, :kind_of => String
attribute :server_admin_url, :kind_of => String
attribute :server_username, :kind_of => String
attribute :server_password, :kind_of => String
attribute :is_hosting, :kind_of => [TrueClass, FalseClass], :default => true

def initialize(*args)
  super
  @action = :install
end
