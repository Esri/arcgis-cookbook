#
# Cookbook Name:: esri-tomcat
# Recipe:: configure_ssl
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

require 'openssl'

instance_name = node['tomcat']['instance_name']
install_path = node['tomcat']['install_path']
dn = node['tomcat']['domain_name']

keystore_file = node['tomcat']['keystore_file']
keystore_password = node['tomcat']['keystore_password']
certs_dir = install_path + '/certificates'

# Generate self-signed SSL certificate if no keystore file and password are provided.
if keystore_file.empty? && (keystore_password.nil? || keystore_password.empty?)
  directory certs_dir do
    owner node['tomcat']['user']
    group node['tomcat']['group']
    action :create
  end

  keystore_file = node.override['tomcat']['keystore_file'] = ::File.join(certs_dir, dn) + '.pfx'
  keystore_password = node.override['tomcat']['keystore_password'] = dn

  openssl_x509_certificate keystore_file.gsub(/\.pfx/, '.pem') do
    common_name node['tomcat']['domain_name']
    org 'test'
    org_unit 'dev'
    country 'US'
    expire 365
    only_if { !::File.exist?(keystore_file) }
    notifies :run, 'ruby_block[Convert to PKCS12]', :immediately
  end

  ruby_block 'Convert to PKCS12' do
    block do
      pfx_file = keystore_file
      keystore_pass = keystore_password
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
# Warn for providing keystore w/o password
elsif !keystore_file.empty? && (keystore_password.nil? || keystore_password.empty?)
  Chef::Log.warn("node['tomcat']['keystore_password'] is not set! SSL will not be configured!")
end

template install_path + '/conf/server.xml' do
  source 'server.xml.erb'
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode '0600'
  notifies :restart, "tomcat_service[#{instance_name}]", :immediately
end
