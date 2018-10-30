#
# Cookbook Name:: arcgis-enterprise
# Attributes:: portal
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

default['arcgis']['portal'].tap do |portal|

  if node['cloud'] || ENV['arcgis_cloud_platform'] == 'aws'
    portal['preferredidentifier'] = 'ip'
  else
    portal['preferredidentifier'] = 'hostname'
  end

  portal['hostname'] = ''
  portal['hostidentifier'] = node['arcgis']['portal']['hostname']

  portal_wa_name = 'portal'
  portal['wa_name'] = portal_wa_name

  unless node['arcgis']['portal']['wa_name'].nil?
    portal_wa_name = node['arcgis']['portal']['wa_name']
  end

  if node['fqdn'].nil? || node['cloud'] || ENV['arcgis_cloud_platform'] == 'aws'
    portal_domain_name = node['ipaddress']
    portal['domain_name'] = portal_domain_name
    portal['url'] = "https://#{node['ipaddress']}:7443/arcgis"
    portal['wa_url'] = "https://#{node['ipaddress']}/#{portal_wa_name}"
  else
    portal_domain_name = node['fqdn']
    portal['domain_name'] = portal_domain_name
    portal['url'] = "https://#{node['fqdn']}:7443/arcgis"
    portal['wa_url'] = "https://#{node['fqdn']}/#{portal_wa_name}"
  end

  unless node['arcgis']['portal']['domain_name'].nil?
    portal_domain_name = node['arcgis']['portal']['domain_name']
  end

  portal['private_url'] = "https://#{portal_domain_name}:7443/arcgis"
  portal['web_context_url'] = ''
    
  portal['http_proxy_host'] = ''
  portal['https_proxy_host'] = ''
  portal['http_proxy_port'] = ''
  portal['https_proxy_port'] = ''
  portal['non_proxy_hosts'] = ''
  portal['http_proxy_user'] = ''
  portal['https_proxy_user'] = ''
  portal['http_proxy_password'] = ''
  portal['https_proxy_password'] = ''
  
  portal['admin_username'] = 'admin'
  if ENV['ARCGIS_PORTAL_ADMIN_PASSWORD'].nil?
    portal['admin_password'] = 'changeit'
  else
    portal['admin_password'] = ENV['ARCGIS_PORTAL_ADMIN_PASSWORD']
  end
  portal['admin_email'] = 'admin@mydomain.com'
  portal['admin_full_name'] = 'Administrator'
  portal['admin_description'] = 'Initial account administrator'
  portal['security_question'] = 'Your favorite ice cream flavor?'
  portal['security_question_answer'] = 'bacon'
  portal['keystore_file'] = ''
  if ENV['ARCGIS_PORTAL_KEYSTORE_PASSWORD'].nil?
    portal['keystore_password'] = ''
  else
    portal['keystore_password'] = ENV['ARCGIS_PORTAL_KEYSTORE_PASSWORD']
  end
  portal['cert_alias'] = portal_domain_name
  portal['root_cert'] = ''
  portal['root_cert_alias'] = ''
  portal['allssl'] = false
  portal['tomcat_java_opts'] = ''
  portal['configure_autostart'] = true
  portal['install_system_requirements'] = true
  unless node['arcgis']['portal']['authorization_file'].nil?
    portal['cached_authorization_file'] = ::File.join(Chef::Config[:file_cache_path],
                                                      ::File.basename(node['arcgis']['portal']['authorization_file']))
  end

  # authorization_file_version must be <major>.<minor> ('10.4.1' -> '10.4')
  portal['authorization_file_version'] = node['arcgis']['version'].to_f.to_s

  portal['security']['user_store_config'] = {'type' => 'BUILTIN', 'properties' => {}}
  portal['security']['role_store_config'] = {'type' => 'BUILTIN', 'properties' => {}}

  portal['log_level'] = 'WARNING'
  portal['max_log_file_age'] = 90
  portal['setup_archive'] = ''
  portal['product_code'] = ''

  portal['living_atlas']['group_ids'] = ['81f4ed89c3c74086a99d168925ce609e', '6646cd89ff1849afa1b95ed670a298b8']

  case node['platform']
  when 'windows'
    portal['authorization_tool'] = ::File.join(ENV['ProgramW6432'],
                                               'Common Files\\ArcGIS\\bin\\SoftwareAuthorization.exe').gsub('/', '\\')
    portal['authorization_file'] = ''
    portal['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  "ArcGIS #{node['arcgis']['version']}",
                                  'PortalForArcGIS', 'Setup.exe').gsub('/', '\\')
    portal['lp-setup'] = node['arcgis']['server']['setup']
    portal['install_dir'] = ::File.join(ENV['ProgramW6432'], 'ArcGIS\\Portal').gsub('/', '\\')
    portal['install_subdir'] = ''
    portal['data_dir'] = 'C:\\arcgisportal'

    case node['arcgis']['version']
    when '10.6.1'
      portal['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'Portal_for_ArcGIS_Windows_1061_163979.exe').gsub('/', '\\')
      portal['product_code'] = '{ECC6B3B9-A875-4AE3-9C03-8664EB38EED9}'
    when '10.6'
      portal['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'Portal_for_ArcGIS_Windows_106_161831.exe').gsub('/', '\\')
      portal['product_code'] = '{FFE4808A-1AD2-41A6-B5AD-2BA312BE6AAA}'
    when '10.5.1'
      portal['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'Portal_for_ArcGIS_Windows_1051_156365.exe').gsub('/', '\\')
      portal['product_code'] = '{C7E44FBE-DFA6-4A95-8779-B6C40F3947B7}'
    when '10.5'
      portal['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'Portal_for_ArcGIS_Windows_105_154005.exe').gsub('/', '\\')
      portal['product_code'] = '{43EF63C6-957B-4DA7-A222-6904053BF222}'
    when '10.4.1'
      portal['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'Portal_for_ArcGIS_Windows_1041_151932.exe').gsub('/', '\\')
      portal['product_code'] = '{31373E04-9B5A-4CD7-B668-0B1DE7F0D45F}'
    when '10.4'
      portal['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'Portal_for_ArcGIS_Windows_104_149434.exe').gsub('/', '\\')
      portal['product_code'] = '{FA6FCD2D-114C-4C04-A8DF-C2E43979560E}'
    else
      Chef::Log.warn 'Unsupported ArcGIS version'
    end
  else # node['platform'] == 'linux'
    portal['install_dir'] = '/'
    portal['install_subdir'] = 'arcgis/portal'

    if node['arcgis']['portal']['install_dir'].nil?
      portal_install_dir = portal['install_dir']
    else
      portal_install_dir = node['arcgis']['portal']['install_dir']
    end

    if node['arcgis']['portal']['install_subdir'].nil?
      portal_install_subdir = portal['install_subdir']
    else
      portal_install_subdir = node['arcgis']['portal']['install_subdir']
    end

    portal['start_tool'] = ::File.join(portal_install_dir,
                                       portal_install_subdir,
                                       'startportal.sh')
    portal['stop_tool'] = ::File.join(portal_install_dir,
                                      portal_install_subdir,
                                      'stopportal.sh')
    portal['authorization_tool'] = ::File.join(portal_install_dir,
                                               portal_install_subdir,
                                               'tools/authorizeSoftware')
    portal['data_dir'] = ::File.join(portal_install_dir,
                                     portal_install_subdir,
                                     'usr/arcgisportal')

    portal['authorization_file'] = ''
    portal['setup'] = ::File.join(node['arcgis']['repository']['setups'],
                                  node['arcgis']['version'],
                                  'PortalForArcGIS', 'Setup')
    portal['lp-setup'] = node['arcgis']['server']['setup']

    case node['arcgis']['version']
    when '10.6.1'
      portal['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'Portal_for_ArcGIS_Linux_1061_164055.tar.gz')
    when '10.6'
      portal['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'Portal_for_ArcGIS_Linux_106_161809.tar.gz')
    when '10.5.1'
      portal['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'Portal_for_ArcGIS_Linux_1051_156440.tar.gz')
    when '10.5'
      portal['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'Portal_for_ArcGIS_Linux_105_154053.tar.gz')
    when '10.4.1'
      portal['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'Portal_for_ArcGIS_Linux_1041_151999.tar.gz')
    when '10.4'
      portal['setup_archive'] = ::File.join(node['arcgis']['repository']['archives'],
                                            'Portal_for_ArcGIS_Linux_104_149447.tar.gz')
    else
      Chef::Log.warn "Unsupported ArcGIS version"
    end
  end

  if node['arcgis']['portal']['data_dir'].nil?
    portal['local_content_dir'] = ::File.join(portal['data_dir'], 'content')
    portal['log_dir'] = ::File.join(portal['data_dir'], 'logs')
  else
    portal['local_content_dir'] = ::File.join(node['arcgis']['portal']['data_dir'], 'content')
    portal['log_dir'] = ::File.join(node['arcgis']['portal']['data_dir'], 'logs')
  end

  if node['arcgis']['portal']['local_content_dir'].nil?
    portal['content_dir'] = portal['local_content_dir']
  else
    portal['content_dir'] = node['arcgis']['portal']['local_content_dir']
  end

  portal['content_store_type'] = 'fileStore'
  portal['content_store_provider'] = 'FileSystem'

  if node['arcgis']['portal']['content_dir'].nil?
    portal['content_store_connection_string'] = portal['content_dir']
  else
    portal['content_store_connection_string'] = node['arcgis']['portal']['content_dir']
  end

  portal['object_store'] = nil
  portal['upgrade_backup'] = true
  portal['upgrade_rollback'] = true
end
