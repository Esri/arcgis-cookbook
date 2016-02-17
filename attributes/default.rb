#
# Cookbook Name:: arcgis
# Attributes:: default
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

default['arcgis']['run_as_user'] = 'arcgis'
default['arcgis']['run_as_password'] = 'Pa$$w0rdPa$$w0rd'
default['arcgis']['version'] = '10.4'

default['arcgis']['server']['domain_name'] = node['fqdn']
default['arcgis']['server']['wa_name'] = 'server'

case ENV['arcgis_cloud_platform']
when 'aws'
  default['arcgis']['server']['local_url'] = 'http://' + node['ipaddress'] + ':6080/arcgis'
  default['arcgis']['server']['local_https_url'] = 'https://' + node['ipaddress'] + ':6443/arcgis'
else
  default['arcgis']['server']['local_url'] = 'http://' + node['fqdn'] + ':6080/arcgis'
  default['arcgis']['server']['local_https_url'] = 'https://' + node['fqdn'] + ':6443/arcgis'
end

default['arcgis']['server']['private_url'] = 'https://' + node['arcgis']['server']['domain_name'] + ':6443/arcgis'
default['arcgis']['server']['url'] = 'https://' + node['arcgis']['server']['domain_name'] + '/' + node['arcgis']['server']['wa_name']
default['arcgis']['server']['admin_username'] = 'admin'
default['arcgis']['server']['admin_password'] = 'changeit'
default['arcgis']['server']['managed_database'] = ''
default['arcgis']['server']['replicated_database'] = ''
default['arcgis']['server']['keystore_file'] = nil
default['arcgis']['server']['keystore_password'] = nil
default['arcgis']['server']['cert_alias'] = node['arcgis']['server']['domain_name']
default['arcgis']['server']['system_properties'] = {}

default['arcgis']['portal']['domain_name'] = node['fqdn']
default['arcgis']['portal']['wa_name'] = 'portal'

case ENV['arcgis_cloud_platform']
when 'aws'
  default['arcgis']['portal']['local_url'] = 'https://' + node['ipaddress'] + ':7443/arcgis'
else
  default['arcgis']['portal']['local_url'] = 'https://' + node['fqdn'] + ':7443/arcgis'
end

default['arcgis']['portal']['url'] = 'https://' + node['arcgis']['portal']['domain_name'] + '/' + node['arcgis']['portal']['wa_name']
default['arcgis']['portal']['private_url'] = 'https://' + node['arcgis']['portal']['domain_name'] + ':7443/arcgis'
default['arcgis']['portal']['web_context_url'] = nil
default['arcgis']['portal']['admin_username'] = 'admin'
default['arcgis']['portal']['admin_password'] = 'changeit'
default['arcgis']['portal']['admin_email'] = 'admin@mydomain.com'
default['arcgis']['portal']['admin_full_name'] = 'Administrator'
default['arcgis']['portal']['admin_description'] = 'Initial account administrator'
default['arcgis']['portal']['security_question'] = 'Your favorite ice cream flavor?'
default['arcgis']['portal']['security_question_answer'] = 'bacon'
default['arcgis']['portal']['keystore_file'] = nil
default['arcgis']['portal']['keystore_password'] = nil
default['arcgis']['portal']['cert_alias'] = node['arcgis']['portal']['domain_name']

case ENV['arcgis_cloud_platform']
when 'aws'
  default['arcgis']['data_store']['preferredidentifier'] = 'ip'
else
  default['arcgis']['data_store']['preferredidentifier'] = 'hostname'
end

default['arcgis']['data_store']['types'] = 'tileCache,relational'

default['arcgis']['web_adaptor']['admin_access'] = false

case node['platform']
when 'windows'
  default['arcgis']['server']['authorization_tool'] = ENV['ProgramW6432'] +'\\Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe'
  default['arcgis']['server']['authorization_file'] = ''
  default['arcgis']['server']['setup'] = 'C:\\Temp\\ArcGISServer\\Setup.exe'
  default['arcgis']['server']['install_dir'] = ENV['ProgramW6432'] + '\\ArcGIS\\Server'
  default['arcgis']['server']['local_directories_root'] = 'C:\\arcgisserver'
  default['arcgis']['server']['directories_root'] = node['arcgis']['server']['local_directories_root']
  default['arcgis']['server']['config_store_type'] = 'FILESYSTEM'
  default['arcgis']['server']['config_store_connection_string'] = ::File.join(node['arcgis']['server']['directories_root'], "config-store")
  default['arcgis']['server']['config_store_connection_secret'] = nil

  default['arcgis']['python']['install_dir'] = 'C:\\Python27'

  default['arcgis']['portal']['authorization_tool'] = ENV['ProgramW6432'] +'\\Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe'
  default['arcgis']['portal']['authorization_file'] = ''
  default['arcgis']['portal']['setup'] = 'C:\\Temp\\ArcGISPortal\\Setup.exe'
  default['arcgis']['portal']['install_dir'] = ENV['ProgramW6432'] + '\\ArcGIS\\Portal'
  default['arcgis']['portal']['data_dir'] = 'C:\\arcgisportal'
  default['arcgis']['portal']['local_content_dir'] = node['arcgis']['portal']['data_dir'] + '\\content'
  default['arcgis']['portal']['content_dir'] = node['arcgis']['portal']['local_content_dir']

  default['arcgis']['web_adaptor']['setup'] = 'C:\\Temp\\WebAdaptorIIS\\Setup.exe'
  default['arcgis']['web_adaptor']['install_dir'] = ''

  default['arcgis']['data_store']['setup'] = 'C:\\Temp\\ArcGISDataStore\\Setup.exe'
  default['arcgis']['data_store']['install_dir'] = ENV['ProgramW6432'] + '\\ArcGIS\\DataStore'
  default['arcgis']['data_store']['data_dir'] = 'C:\\arcgisdatastore'
  default['arcgis']['data_store']['local_backup_dir'] = node['arcgis']['data_store']['data_dir'] + '\\backup'
  default['arcgis']['data_store']['backup_dir'] = node['arcgis']['data_store']['local_backup_dir']

  default['arcgis']['desktop']['setup'] = 'C:\\Temp\\ArcGISDesktop\\Setup.exe'
  default['arcgis']['desktop']['install_dir'] = ENV['ProgramFiles(x86)'] + '\\ArcGIS'
  default['arcgis']['desktop']['install_features'] = 'ALL'
  default['arcgis']['desktop']['authorization_file'] = ''
  default['arcgis']['desktop']['authorization_tool'] = ENV['ProgramFiles(x86)'] + '\\Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe'
  default['arcgis']['desktop']['esri_license_host'] = ENV['COMPUTERNAME']
  default['arcgis']['desktop']['software_class'] = 'Viewer'
  default['arcgis']['desktop']['seat_preference'] = 'Fixed'
  default['arcgis']['desktop']['desktop_config'] = true
  default['arcgis']['desktop']['modifyflexdacl'] = false

  default['arcgis']['pro']['setup'] = 'C:\\Temp\\ArcGISPro\\ArcGISPro.msi'
  default['arcgis']['pro']['install_dir'] = ENV['ProgramW6432'] + '\\ArcGIS\\Pro'
  default['arcgis']['pro']['blockaddins'] = '#0'
  default['arcgis']['pro']['allusers'] = 2

  default['arcgis']['licensemanager']['setup'] = 'C:\\Temp\\ArcGISLicenseManager\\Setup.exe'
  default['arcgis']['licensemanager']['install_dir'] = ENV['ProgramFiles(x86)'] + '\\ArcGIS'

  default['arcgis']['geoevent']['authorization_file'] = ''
  default['arcgis']['geoevent']['authorization_file_version'] = node['arcgis']['server']['authorization_file_version']
  default['arcgis']['geoevent']['setup'] = 'C:\\Temp\\ArcGIS_GeoEventExtension\\setup.exe'

  if node['platform_version'].to_f < 6.1
    # Windows Server 2008
    default['arcgis']['iis']['features'] = ['Web-Server', 'Web-Mgmt-Tools', 'Web-Mgmt-Console',
      'Web-Mgmt-Service', 'Web-Mgmt-Service', 'Web-Mgmt-Compat', 'Web-Scripting-Tools',
      'Web-Static-Content', 'Web-ISAPI-Filter', 'Web-ISAPI-Ext', 'Web-Basic-Auth',
      'Web-Windows-Auth', 'Web-Net-Ext', 'Web-Asp-Net', 'Web-Metabase']
  elsif node['platform_version'].to_f < 6.2
    # Windows Server 2008 R2, Windows 7
    default['arcgis']['iis']['features'] = ['IIS-WebServerRole', 'IIS-ISAPIFilter',
      'IIS-ISAPIExtensions', 'IIS-WebServerManagementTools', 'IIS-ManagementConsole',
      'IIS-ManagementService', 'IIS-IIS6ManagementCompatibility', 'IIS-ManagementScriptingTools',
      'IIS-StaticContent', 'IIS-BasicAuthentication', 'IIS-WindowsAuthentication',
      'IIS-NetFxExtensibility', 'IIS-ASPNET', 'IIS-Metabase']
  else
    if node['kernel']['os_info']['product_type'] != Chef::ReservedNames::Win32::API::System::VER_NT_WORKSTATION
      default['arcgis']['iis']['features'] = ['NetFx3ServerFeatures', 
        'IIS-WebServerRole', 'IIS-ApplicationDevelopment', 'IIS-ISAPIFilter',
        'IIS-ISAPIExtensions', 'NetFx4Extended-ASPNET45', 'IIS-NetFxExtensibility45',
        'IIS-ASPNET45', 'IIS-WebServerManagementTools', 'IIS-ManagementConsole',
        'IIS-ManagementService', 'IIS-IIS6ManagementCompatibility',
        'IIS-ManagementScriptingTools', 'IIS-StaticContent', 'IIS-BasicAuthentication',
        'IIS-WindowsAuthentication', 'IIS-NetFxExtensibility', 'IIS-ASPNET', 'IIS-Metabase']
    elsif
      default['arcgis']['iis']['features'] = ['IIS-WebServerRole', 'IIS-ISAPIFilter',
        'IIS-ISAPIExtensions', 'NetFx4Extended-ASPNET45', 'IIS-NetFxExtensibility45',
        'IIS-ASPNET45', 'IIS-WebServerManagementTools', 'IIS-ManagementConsole',
        'IIS-ManagementService', 'IIS-IIS6ManagementCompatibility',
        'IIS-ManagementScriptingTools', 'IIS-StaticContent', 'IIS-BasicAuthentication',
        'IIS-WindowsAuthentication', 'IIS-NetFxExtensibility', 'IIS-ASPNET', 'IIS-Metabase']
    end
  end
  default['arcgis']['iis']['appid'] = '{00112233-4455-6677-8899-AABBCCDDEEFF}'
  default['arcgis']['iis']['wwwroot'] = 'C:\\inetpub\\wwwroot\\'
  default['arcgis']['iis']['domain_name'] = node['arcgis']['portal']['domain_name']
  # default['arcgis']['iis']['keystore_file'] = nil
  # default['arcgis']['iis']['keystore_password'] = nil

  default['arcgis']['server']['product_code'] = '{687897C7-4795-4B17-8AD0-CB8C364778AD}'
  default['arcgis']['geoevent']['product_code'] = '{188191AE-5A83-49E8-88CB-1F1DB05F030D}'
  default['arcgis']['portal']['product_code'] = '{FA6FCD2D-114C-4C04-A8DF-C2E43979560E}'
  default['arcgis']['web_adaptor']['product_code'] = '{B83D9E06-B57C-4B26-BF7A-004BE10AB2D5}'
  default['arcgis']['web_adaptor']['product_code2'] = '{E2C783F3-6F85-4B49-BFCD-6D6A57A2CFCE}'
  default['arcgis']['data_store']['product_code'] = '{C351BC6D-BF25-487D-99AB-C963D590A8E8}'
  default['arcgis']['desktop']['product_code'] = '{72E7DF0D-FFEE-43CE-A5FA-43DFC25DC087}'
  default['arcgis']['licensemanager']['product_code'] = '{E1393226-725C-42F8-A672-4E5AC55EFBDE}'

  default['arcgis']['server']['authorization_file_version'] = node['arcgis']['version']
  default['arcgis']['portal']['authorization_file_version'] = node['arcgis']['version']
  default['arcgis']['desktop']['authorization_file_version'] = node['arcgis']['version']

else # node['platform'] == 'linux'
  default['arcgis']['web_adaptor']['install_subdir'] = 'arcgis/webadaptor' + node['arcgis']['version']
  default['arcgis']['licensemanager']['install_subdir'] = 'arcgis/license' + node['arcgis']['version']

  default['arcgis']['server']['install_dir'] = '/'
  default['arcgis']['server']['install_subdir'] = 'arcgis/server'
  default['arcgis']['server']['authorization_tool'] = ::File.join(node['arcgis']['server']['install_dir'],
                                                                  node['arcgis']['server']['install_subdir'],
                                                                  '/tools/authorizeSoftware')
  default['arcgis']['server']['authorization_file'] = ''
  default['arcgis']['server']['setup'] = '/tmp/server-cd/Setup'
  default['arcgis']['server']['local_directories_root'] = '/mnt/arcgisserver'
  default['arcgis']['server']['directories_root'] = node['arcgis']['server']['local_directories_root']
  default['arcgis']['server']['config_store_type'] = 'FILESYSTEM'
  default['arcgis']['server']['config_store_connection_string'] = ::File.join(node['arcgis']['server']['directories_root'], "config-store")
  default['arcgis']['server']['config_store_connection_secret'] = nil

  default['arcgis']['python']['install_dir'] = '' # Not needed on Linux.

  default['arcgis']['portal']['install_dir'] = '/'
  default['arcgis']['portal']['install_subdir'] = 'arcgis/portal'
  default['arcgis']['portal']['authorization_tool'] = ::File.join(node['arcgis']['portal']['install_dir'],
                                                                  node['arcgis']['portal']['install_subdir'],
                                                                  '/tools/authorizeSoftware')
  default['arcgis']['portal']['authorization_file'] = ''
  default['arcgis']['portal']['setup'] = '/tmp/portal-cd/Setup'
  default['arcgis']['portal']['data_dir'] = ::File.join(node['arcgis']['portal']['install_dir'],
                                                        node['arcgis']['portal']['install_subdir'],
                                                        'usr/arcgisportal')
  default['arcgis']['portal']['local_content_dir'] = ::File.join(node['arcgis']['portal']['data_dir'], 'content')
  default['arcgis']['portal']['content_dir'] = node['arcgis']['portal']['local_content_dir']

  default['arcgis']['web_adaptor']['setup'] = '/tmp/web-adaptor-cd/Setup'
  default['arcgis']['web_adaptor']['install_dir'] = '/'

  default['arcgis']['data_store']['setup'] = '/tmp/data-store-cd/Setup'
  default['arcgis']['data_store']['install_dir'] = '/'
  default['arcgis']['data_store']['install_subdir'] = 'arcgis/datastore'
  default['arcgis']['data_store']['data_dir'] = ::File.join(node['arcgis']['data_store']['install_dir'],
                                                            node['arcgis']['data_store']['install_subdir'],
                                                            '/usr/arcgisdatastore')
  default['arcgis']['data_store']['local_backup_dir'] = node['arcgis']['data_store']['data_dir'] + '/backup'
  default['arcgis']['data_store']['backup_dir'] = node['arcgis']['data_store']['local_backup_dir']

  default['arcgis']['licensemanager']['setup'] = '/tmp/licensemanager-cd/Setup'
  default['arcgis']['licensemanager']['install_dir'] = '/'

  default['arcgis']['geoevent']['authorization_file'] = ''
  default['arcgis']['geoevent']['authorization_file_version'] = node['arcgis']['server']['authorization_file_version']
  default['arcgis']['geoevent']['setup'] = '/tmp/geo-event-cd/Setup.sh'
end
