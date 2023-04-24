#
# Cookbook Name:: esri-iis
# Recipe:: default
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
#

include_recipe 'esri-iis::install'

require 'openssl'

openssl_x509 node['arcgis']['iis']['keystore_file'].gsub(/\.pfx/, '.pem') do
  common_name node['arcgis']['iis']['domain_name']
  org 'test'
  org_unit 'dev'
  country 'US'
  expire 365
  only_if { !::File.exist?(node['arcgis']['iis']['keystore_file']) }
  notifies :run, 'ruby_block[Convert to PKCS12]', :immediately
end

ruby_block 'Convert to PKCS12' do
  block do
    pfx_file = node['arcgis']['iis']['keystore_file']
    keystore_pass = node['arcgis']['iis']['keystore_password'].nil? ? 
                    node['arcgis']['iis']['domain_name'] :
                    node['arcgis']['iis']['keystore_password']
    cert_file = pfx_file.gsub(/\.pfx/, '.pem')
    key_file = pfx_file.gsub(/\.pfx/, '.key')

    # Convert certificate to PKCS12
    key = OpenSSL::PKey.read(::File.read(key_file))
    cert = OpenSSL::X509::Certificate.new(::File.read(cert_file))
    pkcs12 = OpenSSL::PKCS12.create(keystore_pass, nil, key, cert)

    ::File.open(pfx_file, 'wb') do |output|
      output.write(pkcs12.to_der)
    end
  end
  action :nothing
end

esri_iis_iis 'Configure HTTPS Binding' do
  keystore_file node['arcgis']['iis']['keystore_file']
  keystore_password node['arcgis']['iis']['keystore_password'].nil? ? 
                    node['arcgis']['iis']['domain_name'] :
                    node['arcgis']['iis']['keystore_password']
  web_site node['arcgis']['iis']['web_site']
  replace_https_binding node['arcgis']['iis']['replace_https_binding']
  action :configure_https
end
