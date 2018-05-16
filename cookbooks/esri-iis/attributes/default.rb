#
# Cookbook Name:: esri-iis
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

default['arcgis']['iis'].tap do |iis|

  case node['platform']
  when 'windows'
    if node['platform_version'].to_f < 6.1
      # Windows Server 2008
      iis['features'] = ['Web-Server', 'Web-Mgmt-Tools', 'Web-Mgmt-Console',
        'Web-Mgmt-Service', 'Web-Mgmt-Service', 'Web-Mgmt-Compat', 'Web-Scripting-Tools',
        'Web-Static-Content', 'Web-ISAPI-Filter', 'Web-ISAPI-Ext', 'Web-Basic-Auth',
        'Web-Windows-Auth', 'Web-Net-Ext', 'Web-Asp-Net', 'Web-Metabase']
    elsif node['platform_version'].to_f < 6.2
      # Windows Server 2008 R2, Windows 7
      iis['features'] = ['IIS-WebServerRole', 'IIS-ISAPIFilter',
        'IIS-ISAPIExtensions', 'IIS-WebServerManagementTools', 'IIS-ManagementConsole',
        'IIS-ManagementService', 'IIS-IIS6ManagementCompatibility', 'IIS-ManagementScriptingTools',
        'IIS-StaticContent', 'IIS-BasicAuthentication', 'IIS-WindowsAuthentication',
        'IIS-NetFxExtensibility', 'IIS-ASPNET', 'IIS-Metabase']
    else
      if node['kernel']['os_info']['product_type'] != Chef::ReservedNames::Win32::API::System::VER_NT_WORKSTATION
        iis['features'] = ['NetFx3ServerFeatures',
          'IIS-WebServerRole', 'IIS-ApplicationDevelopment', 'IIS-ISAPIFilter',
          'IIS-ISAPIExtensions', 'NetFx4Extended-ASPNET45', 'IIS-NetFxExtensibility45',
          'IIS-ASPNET45', 'IIS-WebServerManagementTools', 'IIS-ManagementConsole',
          'IIS-ManagementService', 'IIS-IIS6ManagementCompatibility',
          'IIS-ManagementScriptingTools', 'IIS-StaticContent', 'IIS-BasicAuthentication',
          'IIS-WindowsAuthentication', 'IIS-Metabase']
      elsif
        iis['features'] = ['IIS-WebServerRole', 'IIS-ISAPIFilter',
          'IIS-ISAPIExtensions', 'NetFx4Extended-ASPNET45', 'IIS-NetFxExtensibility45',
          'IIS-ASPNET45', 'IIS-WebServerManagementTools', 'IIS-ManagementConsole',
          'IIS-ManagementService', 'IIS-IIS6ManagementCompatibility',
          'IIS-ManagementScriptingTools', 'IIS-StaticContent', 'IIS-BasicAuthentication',
          'IIS-WindowsAuthentication', 'IIS-Metabase']
      end
    end
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
