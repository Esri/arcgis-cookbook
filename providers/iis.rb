#
# Cookbook Name:: arcgis
# Provider:: iis
#
# Copyright 2015 Esri
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

require 'openssl'
require 'digest/md5'

action :enable do
  # Install .Net Framework 3.5 for Windows Server 2012r2
#  if node['platform_version'].to_f >= 6.3
#    if node['kernel']['os_info']['product_type'] != Chef::ReservedNames::Win32::API::System::VER_NT_WORKSTATION
#      windows_feature 'Net-Framework-Core' do
#        provider Chef::Provider::WindowsFeaturePowershell
#        all true
#        action :install
#      end
#    end
#  end

  node['arcgis']['iis']['features'].each do |feature|
    windows_feature feature do
      action :install
    end
  end

  service 'enable W3SVC' do
    service_name 'W3SVC'
    action [:enable]
  end

  new_resource.updated_by_last_action(true)
end

action :configure_https do
  pfx_file = @new_resource.keystore_file
  keystore_pass = @new_resource.keystore_password
  domain_name = @new_resource.domain_name

  cmd = Mixlib::ShellOut.new("%systemroot%\\system32\\inetsrv\\appcmd list site \"Default Web Site\"")
  cmd.run_command
  cmd.error!
  site_info = cmd.stdout

  https_binding_exist = site_info.include?('https/*:443:')

  execute 'Remove HTTPS Binding from Default Web Site' do
    command "%systemroot%\\system32\\inetsrv\\appcmd set site \"Default Web Site\" /-bindings.[protocol='https',bindingInformation='*:443:']"
    only_if { https_binding_exist }
  end

  if pfx_file.nil? || !::File.exist?(pfx_file)
    if pfx_file.nil?
      Chef::Log.warn('SSL certificate file was not specified.')
    else
      Chef::Log.warn("SSL certificate file '#{pfx_file}' was not found.")
    end

    Chef::Log.warn('HTTPS binding will be configured using a self-signed certificate.')

    # Generate self-signed SSL certificate
    cert_file = ::File.join(Chef::Config[:file_cache_path], domain_name + '.pem')
    key_file = ::File.join(Chef::Config[:file_cache_path], domain_name + '.key')
    pfx_file = ::File.join(Chef::Config[:file_cache_path], domain_name + '.pfx')

    keystore_pass = 'test' if keystore_pass.nil?

    openssl_x509 cert_file do
      common_name domain_name
      org 'test'
      org_unit 'dev'
      country 'US'
      expire 365
    end

    ruby_block 'Configure SSL with HTTP.SYS' do
      block do
        # Convert certificate to PKCS12
        key = OpenSSL::PKey.read ::File.read(key_file)
        cert = OpenSSL::X509::Certificate.new ::File.read(cert_file)
        pkcs12 = OpenSSL::PKCS12.create(keystore_pass, nil, key, cert)

        ::File.open(pfx_file, 'wb') do |output|
          output.write pkcs12.to_der
        end

        Utils.configure_ssl(pfx_file, keystore_pass, node['arcgis']['iis']['appid'])
      end
      action :run
    end
  else
    ruby_block 'Configure SSL with HTTP.SYS' do
      block do
        Utils.configure_ssl(pfx_file, keystore_pass, node['arcgis']['iis']['appid'])
      end
      action :run
    end
  end

  execute 'Add HTTPS Binding to Default Web Site' do
    command "%systemroot%\\system32\\inetsrv\\appcmd set site \"Default Web Site\" /+bindings.[protocol='https',bindingInformation='*:443:']"
  end

  new_resource.updated_by_last_action(true)
end

action :start do
  service 'start W3SVC' do
    service_name 'W3SVC'
    action :start
  end

  new_resource.updated_by_last_action(true)
end
