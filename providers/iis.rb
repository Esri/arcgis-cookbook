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
  
#  if node['platform_version'] >= '6.2'
#    features = [
#      "Web-Mgmt-Tools", 
#      "Web-Server",
#      "Web-Mgmt-Console",
#      "Web-Scripting-Tools",
#      "Web-Static-Content",
#      "Web-ISAPI-Filter",
#      "Web-ISAPI-Ext",
#      "Web-Basic-Auth",
#      "Web-Windows-Auth",
#      "Web-Net-Ext",
#      "Web-Asp-Net",
#      #"Web-Asp-Net45",
#      #"Web-Net-Ext45",
#      "Web-Mgmt-Compat",
#      "Web-Metabase",
#      "Web-Mgmt-Service"]
#  else
#    features = [
#      "Web-Mgmt-Tools", 
#      "Web-Server",
#      "Web-Mgmt-Console",
#      "Web-Scripting-Tools",
#      "Web-Static-Content",
#      "Web-ISAPI-Filter",
#      "Web-ISAPI-Ext",
#      "Web-Basic-Auth",
#      "Web-Windows-Auth",
#      "Web-Net-Ext",
#      "Web-Asp-Net",
#      "Web-Mgmt-Compat",
#      "Web-Metabase",
#      "Web-Mgmt-Service"]
#  end

  node['iis']['features'].each do |feature|
    windows_feature feature do
      action :install
    end
  end
    
  service "W3SVC" do
    action [:enable]
  end
  
  new_resource.updated_by_last_action(true)
end

action :configure_https do
  pfx_file = @new_resource.keystore_file
  keystore_pass = @new_resource.keystore_password

  cmd = Mixlib::ShellOut.new("%systemroot%\\system32\\inetsrv\\appcmd list site \"Default Web Site\"")
  cmd.run_command
  cmd.error!
  site_info = cmd.stdout
  
  https_binding_exist = site_info.include? "https/*:443:" 

  if !https_binding_exist
    if pfx_file == nil || !::File.exist?(pfx_file)
      if pfx_file == nil
        Chef::Log.warn("SSL certificate file was not specified.")
      else
        Chef::Log.warn("SSL certificate file '#{pfx_file}' was not found.")
      end
  
      Chef::Log.warn("HTTPS binding will be configured using a self-signed certificate.")
        
      #Generate self-signed SSL certificate
      domain_name = node['fqdn']
      cert_file = ::File.join(Chef::Config[:file_cache_path], domain_name + ".pem")
      key_file = ::File.join(Chef::Config[:file_cache_path], domain_name + ".key")
      pfx_file = ::File.join(Chef::Config[:file_cache_path], domain_name + ".pfx")
        
      if keystore_pass == nil
        keystore_pass = "test"
      end
      
      openssl_x509 cert_file do
        common_name domain_name
        org "test"
        org_unit "dev"
        country "US"
      end
        
      ruby_block "Configure SSL with HTTP.SYS" do
        block do
          #Convert certificate to PKCS12 
          key = OpenSSL::PKey.read ::File.read(key_file)
          cert = OpenSSL::X509::Certificate.new ::File.read(cert_file)
          pkcs12 = OpenSSL::PKCS12.create(keystore_pass, nil, key, cert)
        
          ::File.open(pfx_file, "wb") do |output|
            output.write pkcs12.to_der
          end
          
          Utils.configure_ssl(pfx_file, keystore_pass, node['iis']['appid'])
        end
        action :run
      end
    else
      #There is an easy way in Windows Server 2012
      #    powershell_script "Configure HTTPS Binding in IIS" do
      #      code <<-EOH
      #        Import-Module WebAdministration
      #        $binding = Get-WebBinding -Protocol https -Port 443
      #        if($binding -eq $null) 
      #        {
      #          New-WebBinding -Name "Default Web Site" -IP "*" -Port 443 -Protocol https
      #          $secure_password = convertto-securestring "#{keystore_pass}" -asplaintext -force
      #          $cert = Import-PfxCertificate "#{pfx_file}" -CertStoreLocation "cert:\\LocalMachine\\My" -Password $secure_password
      #          $cert | New-Item "IIS:\\SslBindings\\0.0.0.0!443"
      #        } 
      #      EOH
      #    end
  
      ruby_block "Configure SSL with HTTP.SYS" do
        block do
          Utils.configure_ssl(pfx_file, keystore_pass, node['iis']['appid'])
        end
        action :run
      end
    end    
   
    execute "Add HTTPS Binding to Default Web Site" do
      command "%systemroot%\\system32\\inetsrv\\appcmd set site \"Default Web Site\" /+bindings.[protocol='https',bindingInformation='*:443:']"    
    end
    
    new_resource.updated_by_last_action(true)
  end  
end

action :start do
  service "W3SVC" do
    action [:start]
  end
  
  new_resource.updated_by_last_action(true)
end