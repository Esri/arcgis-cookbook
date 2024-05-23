#
# Cookbook Name:: arcgis-pro
# Recipe:: webview2
#
# Copyright 2024 Esri
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

directory ::File.expand_path("..", node['webview2']['setup']) do
  recursive true
  not_if { ::File.exist?(node['webview2']['setup']) }
  action :create
end

remote_file 'Download Microsoft Edge WebView2' do
  path node['webview2']['setup']
  source node['webview2']['url']
  not_if { ::File.exist?(node['webview2']['setup']) }
end

windows_package 'Install Microsoft Edge WebView2' do
  source node['webview2']['setup']
  installer_type :custom
  options '/silent /install'
  returns [0, 3010]
end
