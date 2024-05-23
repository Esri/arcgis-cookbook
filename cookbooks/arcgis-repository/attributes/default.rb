#
# Cookbook Name:: arcgis-repository
# Attributes:: default
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

# Local ArcGIS Software Repository attributes

default['arcgis']['repository'].tap do |repository|
  if node['platform'] == 'windows'
    repository['setups'] = ::File.join(ENV['USERPROFILE'], 'Documents')
    repository['local_archives'] = ::File.join(ENV['USERPROFILE'], 'Software\\Esri')
  else 
    repository['setups'] = '/opt/arcgis'
    repository['local_archives'] = '/opt/software/esri'
  end

  repository['archives'] = repository['local_archives']
  repository['local_patches'] = ::File.join(node['arcgis']['repository']['local_archives'], 'patches')
  repository['patches'] = repository['local_patches']
  repository['files'] = {}

  repository['shared'] = false

  # Remote ArcGIS Software Repository attributes
  repository['server']['url'] = 'https://downloads.arcgis.com'
  repository['server']['token_service_url'] = 'https://www.arcgis.com/sharing/rest/generateToken'
  repository['server']['username'] = nil
  repository['server']['password'] = nil

  # ArcGIS Software Repository in S3 attributes
  repository['server']['region'] = 'us-east-1'
  repository['server']['s3bucket'] = 'arcgisstore-us-east-1'
  # AWS access keys are required to download files form ArcGIS software repository S3 buckets
  repository['server']['aws_access_key'] = nil
  repository['server']['aws_secret_access_key'] = nil
  
  # AWS CLI v2 URLs and installation directory
  repository['aws_cli']['msi_url'] = 'https://awscli.amazonaws.com/AWSCLIV2.msi'
  repository['aws_cli']['zip_url'] = 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip'
  repository['aws_cli']['bin_dir'] = '/usr/local/bin'
  repository['aws_cli']['install_dir'] = '/usr/local/aws-cli'

  repository['patch_notification']['url'] = 'https://downloads.esri.com/patch_notification/patches.json'
  repository['patch_notification']['versions'] = [node['arcgis']['version']]
  repository['patch_notification']['products'] = []
  repository['patch_notification']['patches'] = []
  repository['patch_notification']['subfolder'] = nil
end

