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

default['server']['domain_name'] = node['fqdn']
default['server']['wa_name'] = 'server'
default['server']['local_url'] = 'http://localhost:6080/arcgis'
default['server']['url'] = 'https://' + node['server']['domain_name'] + '/' + node['server']['wa_name']
default['server']['admin_username'] = 'admin'
default['server']['admin_password'] = 'changeit'
default['server']['managed_database'] = ''
default['server']['replicated_database'] = ''

default['portal']['domain_name'] = node['fqdn']
default['portal']['wa_name'] = 'portal'
default['portal']['local_url'] = 'https://' + node['portal']['domain_name'] + ':7443/arcgis'
default['portal']['url'] = 'https://' + node['portal']['domain_name'] + '/' + node['portal']['wa_name']
default['portal']['admin_username'] = 'admin'
default['portal']['admin_password'] = 'changeit'
default['portal']['admin_email'] = 'admin@mydomain.com'
default['portal']['admin_full_name'] = 'Administrator'
default['portal']['admin_description'] = 'Initial account administrator'
default['portal']['security_question'] = 'Your favorite ice cream flavor?'
default['portal']['security_question_answer'] = 'bacon'

default['data_store']['preferredidentifier'] = 'ip'

case node['platform']
when 'windows'
  default['server']['authorization_tool'] = ENV['ProgramW6432'] +'\\Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe'
  default['server']['authorization_file'] = 'C:\\Temp\\server_license.prvc'
  default['server']['authorization_file_version'] = '10.3'
  default['server']['setup'] = 'C:\\Temp\\ArcGISServer\\Setup.exe'
  default['server']['install_dir'] = ENV['ProgramW6432'] + '\\ArcGIS\\Server'
  default['server']['local_directories_root'] = 'C:\\arcgisserver'
  default['server']['directories_root'] = node['server']['local_directories_root']

  default['python']['install_dir'] = 'C:\\Python27'

  default['portal']['authorization_tool'] = ENV['ProgramW6432'] +'\\Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe'
  default['portal']['authorization_file'] = 'C:\\Temp\\portal_license.prvc'
  default['portal']['authorization_file_version'] = '10.3'
  default['portal']['setup'] = 'C:\\Temp\\ArcGISPortal\\Setup.exe'
  default['portal']['install_dir'] = ENV['ProgramW6432'] + '\\ArcGIS\\Portal'
  default['portal']['local_content_dir'] = 'C:\\arcgisportal\\content'
  default['portal']['content_dir'] = node['portal']['local_content_dir']

  default['web_adaptor']['setup'] = 'C:\\Temp\\WebAdaptorIIS\\Setup.exe'
  default['web_adaptor']['install_dir'] = ''

  default['data_store']['setup'] = 'C:\\Temp\\ArcGISDataStore\\Setup.exe'
  default['data_store']['install_dir'] = ENV['ProgramW6432'] + '\\ArcGIS\\DataStore'
  default['data_store']['data_dir'] = 'C:\\arcgisdatastore\\data'
  default['data_store']['local_backup_dir'] = 'C:\\arcgisdatastore\\data\\backup'
  default['data_store']['backup_dir'] = node['data_store']['local_backup_dir']

  default['desktop']['setup'] = 'C:\\Temp\\ArcGISDesktop\\Setup.exe'
  default['desktop']['install_dir'] = ENV['ProgramFiles(x86)'] + '\\ArcGIS'
  default['desktop']['install_features'] = 'ALL'
  default['desktop']['authorization_file'] = 'C:\\Temp\\license.ecp'
  default['desktop']['authorization_file_version'] = '10.3'
  default['desktop']['authorization_tool'] = ENV['ProgramFiles(x86)'] + '\\Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe'
  default['desktop']['esri_license_host'] = ENV['COMPUTERNAME']
  default['desktop']['software_class'] = 'Viewer'
  default['desktop']['seat_preference'] = 'Fixed'

  default['licensemanager']['setup'] = 'C:\\Temp\ArcGISLicenseManager\\Setup.exe'
  default['licensemanager']['install_dir'] = ENV['ProgramFiles(x86)'] + '\\ArcGIS'

  default['dotnetframework']['3.5.1']['url'] = 'http://download.microsoft.com/download/2/0/e/20e90413-712f-438c-988e-fdaa79a8ac3d/dotnetfx35.exe'
  if node['platform_version'].to_f < 6.1
    #Windows Server 2008
    default['iis']['features'] = ["Web-Server", "Web-Mgmt-Tools", "Web-Mgmt-Console", "Web-Mgmt-Service",
        "Web-Mgmt-Service", "Web-Mgmt-Compat", "Web-Scripting-Tools", "Web-Static-Content",
        "Web-ISAPI-Filter", "Web-ISAPI-Ext", "Web-Basic-Auth", "Web-Windows-Auth", "Web-Net-Ext",
        "Web-Asp-Net", "Web-Metabase"]
  elsif node['platform_version'].to_f < 6.2
    #Windows Server 2008 R2, Windows 7
    default['iis']['features'] = ["IIS-WebServerRole", "IIS-ISAPIFilter", "IIS-ISAPIExtensions",
        "IIS-WebServerManagementTools", "IIS-ManagementConsole", "IIS-ManagementService",
        "IIS-IIS6ManagementCompatibility", "IIS-ManagementScriptingTools", "IIS-StaticContent",
        "IIS-BasicAuthentication", "IIS-WindowsAuthentication", "IIS-NetFxExtensibility",
        "IIS-ASPNET", "IIS-Metabase"]
  else
    default['iis']['features'] = ["IIS-WebServerRole", "IIS-ISAPIFilter", "IIS-ISAPIExtensions",
        "NetFx4Extended-ASPNET45", "IIS-NetFxExtensibility45", "IIS-ASPNET45",
        "IIS-WebServerManagementTools", "IIS-ManagementConsole", "IIS-ManagementService",
        "IIS-IIS6ManagementCompatibility", "IIS-ManagementScriptingTools", "IIS-StaticContent",
        "IIS-BasicAuthentication", "IIS-WindowsAuthentication", "IIS-NetFxExtensibility",
        "IIS-ASPNET", "IIS-Metabase"]
  end
  default['iis']['appid'] = '{00112233-4455-6677-8899-AABBCCDDEEFF}'
  #default['iis']['keystore_file'] = nil
  #default['iis']['keystore_password'] = nil
else
  default['server']['authorization_tool'] = '/arcgis/server/tools/authorizeSoftware'
  default['server']['authorization_file'] = '/tmp/server_license.prvc'
  default['server']['setup'] = '/tmp/server-cd/Setup'
  default['server']['install_dir'] = '/'
  default['server']['install_subdir'] = 'arcgis/server'
  default['server']['local_directories_root'] = '/mnt/arcgisserver'
  default['server']['directories_root'] = node['server']['local_directories_root']

  default['python']['install_dir'] = '/arcgis/python27'

  default['portal']['authorization_tool'] = '/arcgis/portal/tools/authorizeSoftware'
  default['portal']['authorization_file'] = '/tmp/portal_license.prvc'
  default['portal']['setup'] = '/tmp/portal-cd/Setup'
  default['portal']['install_dir'] = '/'
  default['portal']['install_subdir'] = 'arcgis/portal'
  default['portal']['local_content_dir'] = ::File.join(node['portal']['install_dir'], node['portal']['install_subdir'], 'usr/arcgisportal/content')
  default['portal']['content_dir'] = node['portal']['local_content_dir']

  default['web_adaptor']['setup'] = '/tmp/web-adaptor-cd/Setup'
  default['web_adaptor']['install_dir'] = '/'
  default['web_adaptor']['install_subdir'] = 'arcgis/webadaptor10.3.1'

  default['data_store']['setup'] = '/tmp/data-store-cd/Setup'
  default['data_store']['install_dir'] = '/'
  default['data_store']['install_subdir'] = 'arcgis/datastore'
  default['data_store']['data_dir'] = '/mnt/arcgisdatastore/data'
  default['data_store']['local_backup_dir'] = node['data_store']['data_dir'] + '/backup'
  default['data_store']['backup_dir'] = node['data_store']['local_backup_dir']

  default['licensemanager']['setup'] = '/tmp/licensemanager-cd/Setup'
  default['licensemanager']['install_dir'] = '/'
  default['licensemanager']['install_subdir'] = 'arcgis/license10.3'
end
