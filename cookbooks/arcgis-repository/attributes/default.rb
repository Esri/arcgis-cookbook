#
# Cookbook Name:: arcgis-repository
# Attributes:: default
#
# Copyright 2018 Esri
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
  case node['platform']
  when 'windows'
    repository['setups'] = ::File.join(ENV['USERPROFILE'],
                                       'Documents')
    repository['local_archives'] = ::File.join(ENV['USERPROFILE'],
                                               'Software\\Esri')
    repository['archives'] = repository['local_archives']
    repository['patches'] = ::File.join(ENV['USERPROFILE'],
                                        'Software\\Esri\\Patches')
  else # node['platform'] == 'linux'
    repository['setups'] = '/opt/arcgis'
    repository['local_archives'] = '/opt/software/esri'
    repository['archives'] = repository['local_archives']
    repository['patches'] = '/opt/software/esri/patches'
  end

  # Remote ArcGIS Software Repository attributes
  repository['server']['url'] = 'https://downloads.arcgis.com/dms/rest/download/secured'
  repository['server']['key'] = ''

  # ArcGIS Software Repository in S3 attributes
  repository['server']['region'] = ''
  repository['server']['s3bucket'] = ''

  # AWS access keys are required to download files form ArcGIS software repository S3 buckets
  repository['server']['aws_access_key'] = ''
  repository['server']['aws_secret_access_key'] = ''
end
