#
# Cookbook Name:: arcgis
# Recipe:: iis
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

arcgis_iis 'Enable IIS Features' do
  action :enable
end

arcgis_iis 'Configure HTTPS Binding' do
  keystore_file node['arcgis']['iis']['keystore_file']
  keystore_password node['arcgis']['iis']['keystore_password']
  domain_name node['arcgis']['iis']['domain_name']
  action :configure_https
end

arcgis_iis 'Start IIS' do
  action :start
end
