#
# Cookbook Name:: esri-tomcat
# Recipe:: configure_ssl
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'openssl'

instance_name = node['tomcat']['instance_name']
install_path = node['tomcat']['install_path']
dn = node['tomcat']['domain_name']

keystore_file = node['tomcat']['keystore_file']
keystore_password = node['tomcat']['keystore_password']
certs_dir = install_path + '/certificates'

# Generate Self Signed if no keystore is provided
if keystore_file.empty? && keystore_password.empty?
  directory certs_dir do
    owner node['tomcat']['user']
    group node['tomcat']['group']
    action :create
  end

  keystore_file = node.override['tomcat']['keystore_file'] = ::File.join(certs_dir, dn) + '.pfx'
  keystore_password = node.override['tomcat']['keystore_password'] = 'changeit'

  openssl_x509 keystore_file.gsub(/\.pfx/, '.pem') do
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
elsif !keystore_file.empty? && keystore_password.empty?
  Chef::Log.warn("node['tomcat']['keystore_password'] is empty! SSL will not be configured!")
end

template install_path + '/conf/server.xml' do
  source 'server.xml.erb'
  owner node['tomcat']['user']
  group node['tomcat']['group']
  mode '0600'
  notifies :restart, "tomcat_service[#{instance_name}]", :immediately
end
