#
# Cookbook Name:: esri-iis
# Attributes:: default
#
# Copyright 2022 Esri
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

default['arcgis']['iis'].tap do |iis|

  case node['platform']
  when 'windows'
    iis['features'] = ['IIS-WebServerRole', 'IIS-WebServer']
    iis['appid'] = '{00112233-4455-6677-8899-AABBCCDDEEFF}'
    iis['domain_name'] = node['fqdn']
    iis['keystore_file'] = ::File.join(Chef::Config[:file_cache_path],
                                       node['arcgis']['iis']['domain_name'] + '.pfx')
    if ENV['ARCGIS_IIS_KEYSTORE_PASSWORD'].nil?
      iis['keystore_password'] = 'test'
    else
      iis['keystore_password'] = ENV['ARCGIS_IIS_KEYSTORE_PASSWORD']
    end
    iis['web_site'] = 'Default Web Site'
    iis['replace_https_binding'] = false
  end

end
