#
# Cookbook Name:: esri-tomcat
# Recipe:: openjdk
#
# Copyright 2021 Esri
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

remote_file "download jdk #{node['java']['version']} tarball" do
  source node['java']['tarball_uri']
  path node['java']['tarball_path']
  not_if { ::File.exist?(node['java']['tarball_path']) }
end

execute 'extract jdk tarball' do
  command "tar -xvf #{node['java']['tarball_path']} -C #{node['java']['install_path']}"
  action :run
end

execute 'update java alternatives' do
  command "update-alternatives --install /usr/bin/java java #{node['java']['install_path']}/jdk-#{node['java']['version']}/bin/java 10"
end
