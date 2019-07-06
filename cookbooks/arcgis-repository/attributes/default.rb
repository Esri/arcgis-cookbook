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
  repository_s3buckets = {
    'ap-south-1' => 'arcgisstore107-ap-south-1',
    'eu-north-1' => 'arcgisstore107-eu-north-1',
    'eu-west-3' => 'arcgisstore107-eu-west-3',
    'eu-west-2' => 'arcgisstore107-eu-west-2',
    'eu-west-1' => 'arcgisstore107-eu-west-1',
    'ap-northeast-2' => 'arcgisstore107-ap-northeast-2',
    'ap-northeast-1' => 'arcgisstore107-ap-northeast-1',
    'sa-east-1' => 'arcgisstore107-sa-east-1',
    'ca-central-1' => 'arcgisstore107-ca-central-1',
    'ap-southeast-1' => 'arcgisstore107-ap-southeast-1',
    'ap-southeast-2' => 'arcgisstore107-ap-southeast-2',
    'eu-central-1' => 'arcgisstore107-eu-central-1',
    'us-east-1' => 'arcgisstore107-us-east-1',
    'us-east-2' => 'arcgisstore107-us-east-2',
    'us-west-1' => 'arcgisstore107-us-west-1',
    'us-west-2' => 'arcgisstore107-us-west-2',
    'us-gov-west-1' => 'arcgisstore107-us-gov-west-1',
    'us-gov-east-1' => 'arcgisstore107-us-gov-east-1'
  }

  repository['server']['region'] = 'us-east-1'
  repository['server']['s3bucket'] = repository_s3buckets[node['arcgis']['repository']['server']['region']]

  # AWS access keys are required to download files form ArcGIS software repository S3 buckets
  repository['server']['aws_access_key'] = ''
  repository['server']['aws_secret_access_key'] = ''

  # if node['platform'] == 'windows'
  #   repository['files'] = {
  #     'ArcGIS_DataStore_Windows_107_167633.exe' => {
  #       'subfolder' => '10450/setups',
  #       'checksum' => 'A28C8CA67DB7ECCE8AFF41CD0B88EB781C05D7949AD495DEF9045FEAEED6E3C4'
  #     },
  #     'ArcGIS_Server_Windows_107_167621.exe' => {
  #       'subfolder' => '10450/setups',
  #       'checksum' => '444FC3FB1D11A715FAA355A0587D7E71F0AE4873EC3C9F00BE98AD04566D2CD2'
  #     },
  #     'Portal_for_ArcGIS_Windows_107_167632.exe' => {
  #       'subfolder' => '10450/setups',
  #       'checksum' => 'BDC20B9A19515966864953E85E25E174E58877B934157AA33EFB1443314B80E5'
  #     },
  #     'Web_Adaptor_for_Microsoft_IIS_107_167634.exe' => {
  #       'subfolder' => '10450/setups',
  #       'checksum' => '714C20ACD19663CCAE8A1BF2ABBEF70F46E53BF83626DE13483348BBBB056A2C'
  #     }
  #   }
  # else # Linux
  #   repository['files'] = {
  #     'ArcGIS_DataStore_Linux_107_167719.tar.gz' => {
  #       'subfolder' => '10450/setups',
  #       'checksum' => 'A8DBE53A19838120ED99D352654174B37B31163E173AD0D26B47A15872E4245C'
  #     },
  #     'ArcGIS_Server_Linux_107_167707.tar.gz' => {
  #       'subfolder' => '10450/setups',
  #       'checksum' => '350B985F8CF900A27C0043561CFA092930A1CCA2352A1DECABA4DD378ECA1492'
  #     },
  #     'Portal_for_ArcGIS_Linux_107_167718.tar.gz' => {
  #       'subfolder' => '10450/setups',
  #       'checksum' => '12E362E7542EF1BB3EB04E605BB99F1B1D181644C4E7C6C2B19B6601AF50595B'
  #     },
  #     'Web_Adaptor_Java_Linux_107_167720.tar.gz' => {
  #       'subfolder' => '10450/setups',
  #       'checksum' => 'F0773EE8BFF83FFFB40FB0AF232BCB988BCF49B4491A1BAD6F8852F71AA7B3A6'
  #     }
  #   }
  # end
end
