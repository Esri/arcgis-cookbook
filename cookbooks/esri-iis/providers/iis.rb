#
# Cookbook Name:: esri-iis
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

use_inline_resources

action :configure_https do
  pfx_file = @new_resource.keystore_file
  keystore_pass = @new_resource.keystore_password
  site = @new_resource.web_site

  cmd = Mixlib::ShellOut.new("%systemroot%\\system32\\inetsrv\\appcmd list site \"#{site}\"")
  cmd.run_command
  cmd.error!

  https_binding_exists = cmd.stdout.include?('https/*:443:')

  if https_binding_exists && @new_resource.replace_https_binding
    cmd = Mixlib::ShellOut.new("%systemroot%\\system32\\inetsrv\\appcmd set site \"#{site}\" /-bindings.[protocol='https',bindingInformation='*:443:']")
    cmd.run_command
    cmd.error!

    https_binding_exists = false
  end

  if !https_binding_exists
    # Configure SSL with HTTP.SYS
    appid = node['arcgis']['iis']['appid']

    pkcs12 = OpenSSL::PKCS12.new(::File.binread(pfx_file), keystore_pass)
    certhash = Digest::SHA1.hexdigest(pkcs12.certificate.to_der)

    cmd = Mixlib::ShellOut.new("certutil -f -p \"#{keystore_pass}\" -importpfx \"#{pfx_file}\"")
    cmd.run_command
    cmd.error!

    cmd = Mixlib::ShellOut.new("netsh http delete sslcert ipport=0.0.0.0:443")
    cmd.run_command

    cmd = Mixlib::ShellOut.new("netsh http add sslcert ipport=0.0.0.0:443 certhash=#{certhash} appid=#{appid}")
    cmd.run_command
    cmd.error!

    # Add HTTPS Binding to Default Web Site
    cmd = Mixlib::ShellOut.new("%systemroot%\\system32\\inetsrv\\appcmd set site \"#{site}\" /+bindings.[protocol='https',bindingInformation='*:443:']")
    cmd.run_command
    cmd.error!

    new_resource.updated_by_last_action(true)
  end
end
