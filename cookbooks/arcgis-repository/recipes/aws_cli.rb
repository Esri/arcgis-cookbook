#
# Cookbook:: arcgis-repository
# Recipe:: aws_cli
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
#

if node['platform'] == 'windows'
  windows_package 'Install AWS CLI' do
    source node['arcgis']['repository']['aws_cli']['msi_url']
    options '/qn'
    installer_type :msi
    returns [0, 3010, 1638]
    not_if 'aws --version'
    action :install
  end

  # Add AWS CLI path to PATH env variable to use in the current Chef run.
  ENV['PATH'] = "#{ENV['PATH']};C:\\Program Files\\Amazon\\AWSCLIV2"
else
  package 'unzip'

  remote_file 'Download AWS CLI Linux ZIP' do
    path "#{Chef::Config['file_cache_path']}/awscliv2.zip"
    source node['arcgis']['repository']['aws_cli']['zip_url']
    not_if  { ::File.exist?(::File.join(node['arcgis']['repository']['aws_cli']['bin_dir'], 'aws')) }
    action :create
  end

  execute 'Install AWS CLI' do
    command "unzip awscliv2.zip && sudo ./aws/install"\
            " --install-dir #{node['arcgis']['repository']['aws_cli']['install_dir']}"\
            " --bin-dir #{node['arcgis']['repository']['aws_cli']['bin_dir']}"
    cwd Chef::Config['file_cache_path']
    not_if  { ::File.exist?(::File.join(node['arcgis']['repository']['aws_cli']['bin_dir'], 'aws')) }
  end
end
