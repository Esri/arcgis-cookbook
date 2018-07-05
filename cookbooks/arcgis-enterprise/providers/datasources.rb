#
# Cookbook Name:: arcgis-enterprise
# Provider:: datasources
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

action :create_ags_connection_file do
  server_url = get_server_url
  username = @new_resource.admin_user
  password = @new_resource.admin_password
  out_dir = ::File.dirname(node['arcgis']['datasources']['ags_connection_file'])
  ags_connection_file_name = ::File.basename(node['arcgis']['datasources']['ags_connection_file'])

  # create an ArcGIS Server Connection file which is needed for the following registration process
  python_script_file = ::File.join(node['arcgis']['misc']['scripts_dir'], 'CreateGISServerConnectionFile.py')
  execute 'Create ArcGIS Server Connection File' do
    cwd node['arcgis']['python']['runtime_environment']
    command "python #{python_script_file} #{server_url} #{username} #{password} #{out_dir} #{ags_connection_file_name}"
  end
end

action :create_folder do
  folder = @new_resource.folder
  
  unless folder['security_permissions']['full_control_members'].nil?
    folder['security_permissions']['full_control_members'].each do |full_control_member|
      directory folder['server_path'] do
        rights :full_control, full_control_member, :applies_to_children => true
        action :create
      end
    end
  end
  
  if @new_resource.authorize_arcgis_service_account == true
    directory folder['server_path'] do
      rights :full_control, node['arcgis']['run_as_user'], :applies_to_children => true
      action :create
    end
  end
end

action :share_folder do
  folder = @new_resource.folder
  share_name = folder['share_name']
      
  # the following PowerShell commands for creating shares expect the members in a comma-separated format
  concatenated_members = folder['sharing_permissions']['full_control_members'].join(""",""")
  concatenated_members = """" + concatenated_members + """"
  
  # To share the previously created directories, a PowerShell script has to be executed.
  # The script checks whether the share exists, creates it when absent or
  # recreates it when existing
  powershell_script "Share directory #{share_name}" do
    code <<-EOH
    # the SMBShare-Cmdlet was introduced with Windows Server 2012. Due to this circumstance, the ELSE-Branch contains
    # the former, more elaborate way of creating shares to support older versions of Windows Server (e. g. 2008).
    if (Get-Command "Get-SMBShare" -errorAction SilentlyContinue) {
      # delete old share if it exists
      if (Get-SMBShare -Name "#{share_name}" -ea 0) {
        Remove-SmbShare -Name "#{share_name}" -Force
      }
      New-SMBShare -Name "#{share_name}" -Path "#{folder['server_path']}" -FullAccess #{concatenated_members}
    }
    else {
      # delete old share if it exists
      if ($share = Get-WmiObject -Class Win32_Share -Filter "Name='#{share_name}'") {
        $share.delete()
      }
  
      # split the comma-separated accounts into a PowerShell array
      $FullyQualifiedDomainUsers = "#{concatenated_members}".split(",")

      # SecurityDescriptor containting access
      $sd = ([wmiclass]'Win32_SecurityDescriptor').psbase.CreateInstance()
      $sd.ControlFlags = 4

      $aces = New-Object System.Collections.ArrayList
      ForEach($FullyQualifiedDomainUser in $FullyQualifiedDomainUsers) {
        # distinguish between domain and non-domain accounts
        $splittedStrings = $FullyQualifiedDomainUser.Split("\\")
        if ($splittedStrings.length -eq 1) {
          $Domain = $Null
          $User = $FullyQualifiedDomainUser
        }
        elseif ($splittedStrings.length -eq 2) {
          $Domain = $splittedStrings[0]
          $User = $splittedStrings[1]
        }
        else {
          throw "Format of provided user '$FullyQualifiedDomainUser' is not supported. The string must only contain one backslash."
        }
        
        # Username/Group to give permissions to
        $trustee = ([wmiclass]'Win32_trustee').psbase.CreateInstance()
        $trustee.Domain = $Domain
        $trustee.Name = $User

        # Accessmask values
        $fullcontrol = 2032127

        # Create access-list
        $ace = ([wmiclass]'Win32_ACE').psbase.CreateInstance()
        $ace.AccessMask = $fullcontrol
        $ace.AceFlags = 3
        $ace.AceType = 0
        $ace.Trustee = $trustee

        # add current account to list off all accounts that should get permissions
        $aces.Add($ace) > $null
      }

      $sd.DACL = $aces

      $Shares=[WMICLASS]"WIN32_Share"
      $retObj = $Shares.Create("#{folder['server_path']}", "#{share_name}", 0, 20, "", "", $sd)
      Exit $retObj.ReturnValue
    }
    EOH
  end
end

action :register_folder do
  folder = @new_resource.folder
  folder_identifier = folder['publish_folder']['identifier']
      
  if @new_resource.publish_with_hostname == true
    publisher_path = "\\\\" + ENV['COMPUTERNAME'] + "\\" + folder['share_name']
    command_arguments = "#{folder_identifier} #{folder['server_path']} #{publisher_path}"
  end
  
  if @new_resource.publish_with_fqdn == true
    publisher_path = "\\\\" + node['fqdn'] + "\\" + folder['share_name']
    command_arguments = "#{folder_identifier} #{folder['server_path']} #{publisher_path}"
  end
  
  if @new_resource.publish_with_alternative_path == true
    # ArcGIS Server allows to use different folders for publishing and on the server 
    # => this can be set here
    publisher_path = folder['publish_folder']['publish_alternative_path']
    if folder['server_path'].nil?
      command_arguments = "#{folder_identifier} #{publisher_path}"
    else
      command_arguments = "#{folder_identifier} #{folder['server_path']} #{publisher_path}"
    end
  end
  
  python_script_file = ::File.join(node['arcgis']['misc']['scripts_dir'], 'RegisterFolderAsDatasource.py')
  execute "Register folder #{folder_identifier} as datasource" do
    cwd node['arcgis']['python']['runtime_environment']
    command "python #{python_script_file} #{node['arcgis']['datasources']['ags_connection_file']} #{command_arguments}"
  end
end

action :register_sde_files do
  # Dir.glob() doesn't support backslashes within a path, so they will be replaces on Windows
  if node['platform'] == 'windows'
    folder = node['arcgis']['datasources']['sde_files']['folder'].gsub('\\','/')
  else
    folder = node['arcgis']['datasources']['sde_files']['folder']
  end

  # get all SDE files within the specified folder and register them
  Dir.glob("#{folder}/**/*.sde") do |sde_file|
    register_sde_file(sde_file)
  end
end

action :register_sde_files_from_folder do
  # iterate over all specified SDE files and register them
  node['arcgis']['datasources']['sde_files']['files'].each do |sde_file|
    register_sde_file(sde_file)
  end
end

action :delete_ags_connection_file do
  file node['arcgis']['datasources']['ags_connection_file'] do
    action :delete
  end
end

private

def register_sde_file(sde_file)
  sde_name = ::File.basename(sde_file, ".*")
  python_script_file = ::File.join(node['arcgis']['misc']['scripts_dir'], 'RegisterSdeFileAsDatasource.py')
  execute "Register SDE #{sde_name} as datasource" do
    cwd node['arcgis']['python']['runtime_environment']
    command "python #{python_script_file} #{node['arcgis']['datasources']['ags_connection_file']} #{sde_name} #{sde_file}"
  end
end

def get_server_url
  # retrieve URL to configure ArcGIS Server via HTTPS:
  # 1. Check whether a dedicated parameter has been specified
  # 2. Read the SSL certificate and construct the URL out of the certificat's subject name
  # 3. Use existing Cookbook parameter as fallback (high chance that this results in certificate errors)
  if !node['arcgis']['datasources']['server_config_url'].nil?
    server_url = node['arcgis']['datasources']['server_config_url'] + "/admin"
  else
    if ::File.exist?(node['arcgis']['server']['keystore_file'])
      p12 = OpenSSL::PKCS12.new(::File.binread(node['arcgis']['server']['keystore_file']), node['arcgis']['server']['keystore_password'])
      cert = p12.certificate
      cert_cn = cert.subject.to_a.select{|name, _, _| name == 'CN' }.first[1]
      
      server_url = 'https://' + cert_cn + ":6443/arcgis/admin"
    else
      server_url = node['arcgis']['server']['url'] + "/admin"
    end
  end
  
  server_url
end