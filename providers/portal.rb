#
# Cookbook Name:: arcgis
# Provider:: portal
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
require 'fileutils'
require 'pathname'

if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  require 'win32/service'
end

action :system do
  arcgis_user @new_resource.recipe_name + ':create-portal-account'

  case node['platform']
  when 'windows'
  when 'redhat', 'centos'
    ['mesa-libGLU', 'libXdmcp', 'xorg-x11-server-Xvfb'].each do |pckg|
      yum_package @new_resource.recipe_name + ':portal:' + pckg do
        options '--enablerepo=*-optional'
        package_name pckg
        action :install
      end
    end
  when 'suse'
    ['libGLU1', 'libXdmcp6', 'xorg-x11-server', 'libXfont1'].each do |pckg|
      package @new_resource.recipe_name + ':portal:' + pckg do
        package_name pckg
        action :install
      end
    end
  else
    # NOTE: ArcGIS products are not officially supported on debian platform family
    ['xserver-common', 'xvfb', 'libfreetype6', 'libfontconfig1', 'libxfont1',
     'libpixman-1-0', 'libgl1-mesa-dri', 'libgl1-mesa-glx', 'libglu1-mesa',
     'libpng12-0', 'x11-xkb-utils', 'libapr1', 'libxrender1', 'libxi6',
     'libxtst6', 'libaio1', 'nfs-kernel-server', 'autofs'].each do |pckg|
      package @new_resource.recipe_name + ':portal:' + pckg do
        package_name pckg
        action :install
      end
    end
  end

  new_resource.updated_by_last_action(true)
end

action :install do
  if node['platform'] == 'windows'
    cmd = @new_resource.setup
    args = "/qb INSTALLDIR=\"#{@new_resource.install_dir}\" "\
           "CONTENTDIR=\"#{node['arcgis']['portal']['data_dir']}\" "\
           "USER_NAME=\"#{@new_resource.run_as_user}\" "\
           "PASSWORD=\"#{@new_resource.run_as_password}\""

    installed = ::Win32::Service.exists?('Portal for ArcGIS')

    execute 'Install Portal for ArcGIS' do
      command "\"#{cmd}\" #{args}"
      timeout 7200
      notifies :run, 'ruby_block[Wait for Portal installation to finish]', :immediately
      not_if { installed }
    end

    # After setup is completed Portal still copies data to content directory
    ruby_block 'Wait for Portal installation to finish' do
      block do
        sleep(600.0)  
      end
      action :nothing
    end

    configureserviceaccount = ::File.join(@new_resource.install_dir,
                                          'tools', 'ConfigUtility',
                                          'configureserviceaccount.bat')

    args = "/username #{@new_resource.run_as_user} "\
           "/password #{@new_resource.run_as_password}"

    execute 'portal.configureserviceaccount' do
      command "cmd.exe /C \"\"#{configureserviceaccount}\" #{args}\""
      only_if { installed }
    end

    install_dir = @new_resource.install_dir
    run_as_user = @new_resource.run_as_user

    execute 'Grant portal service account access to install directory' do
      command "icacls.exe \"#{install_dir}\" /grant \"#{run_as_user}:(OI)(CI)F\""
      only_if { ::File.exist?(install_dir) }
    end

    service 'Portal for ArcGIS' do
      action [:enable, :start]
    end
  else
    cmd = @new_resource.setup
    args = "-m silent -l yes -d \"#{@new_resource.install_dir}\""
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['portal']['install_subdir'])
    start_portal_path = ::File.join(install_subdir, 'startportal.sh')
    dir_data = @new_resource.data_dir
    run_as_user = @new_resource.run_as_user

    subdir = @new_resource.install_dir
    node['arcgis']['portal']['install_subdir'].split('/').each do |path|
      subdir = ::File.join(subdir, path)
      directory subdir do
        owner run_as_user
        group 'root'
        mode '0755'
        action :create
      end
    end

    execute 'Install Portal for ArcGIS' do
      command "su - #{run_as_user} -c \"#{cmd} #{args}\""
      only_if { !::File.exist?(start_portal_path) }
      notifies :run, 'ruby_block[Wait for Portal installation to finish]', :immediately
    end

    # After setup is completed Portal still copies data to content directory
    ruby_block 'Wait for Portal installation to finish' do
      block do
        sleep(600.0)  
      end
      action :nothing
    end

    ruby_block 'Set dir.data property' do
      block do
        properties_filename = ::File.join(install_subdir,
                                          'framework', 'etc',
                                          'portal-config.properties')

        if ::File.exist?(properties_filename)
          file = Chef::Util::FileEdit.new(properties_filename)
          file.search_file_replace_line(/dir.data.*/, "dir.data=#{dir_data}")
          file.write_file
        else
          ::File.open(properties_filename, 'w') { |f| f.write("dir.data=#{dir_data}") }
        end
      end
      not_if { dir_data == node.default['arcgis']['portal']['data_dir'] }
    end

    configure_autostart(install_subdir)
  end

  new_resource.updated_by_last_action(true)
end

action :uninstall do
  if node['platform'] == 'windows'
    cmd = 'msiexec'
    product_code = @new_resource.product_code
    args = "/qb /x #{product_code}"

    execute 'Uninstall Portal for ArcGIS' do
      command "\"#{cmd}\" #{args}"
      only_if { Utils.product_installed?(product_code) }
    end
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['portal']['install_subdir'])
    cmd = ::File.join(install_subdir, 'uninstall_ArcGISPortal')
    args = '-s'

    execute 'Uninstall Portal for ArcGIS' do
      command "su - #{node['arcgis']['run_as_user']} -c \"#{cmd} #{args}\""
      only_if { ::File.exist?(cmd) }
    end
  end

  new_resource.updated_by_last_action(true)
end

action :authorize do
  cmd = node['arcgis']['portal']['authorization_tool']

  if node['platform'] == 'windows'
    args = "/VER #{@new_resource.authorization_file_version} "\
           "/LIF \"#{@new_resource.authorization_file}\" /S"

    execute 'Authorize Portal for ArcGIS' do
      command "\"#{cmd}\" #{args}"
      retries 3
      retry_delay 60
    end
  else
    args = "-f \"#{@new_resource.authorization_file}\""

    execute 'Authorize Portal for ArcGIS' do
      command "\"#{cmd}\" #{args}"
      user node['arcgis']['run_as_user']
      retries 3
      retry_delay 60
    end
  end

  new_resource.updated_by_last_action(true)
end

action :create_site do
  portal_admin_client = ArcGIS::PortalAdminClient.new(
    @new_resource.portal_local_url,
    @new_resource.username,
    @new_resource.password)

  portal_admin_client.wait_until_available

  if portal_admin_client.site_exist?
    Chef::Log.info('Portal site already exists.')
  else
    Chef::Log.info('Creating portal site...')

    portal_admin_client.create_site(@new_resource.email,
                                    @new_resource.full_name,
                                    @new_resource.description,
                                    @new_resource.security_question,
                                    @new_resource.security_question_answer,
                                    @new_resource.content_dir)

    sleep(120.0)

    portal_admin_client.wait_until_available

    system_properties = {}

    unless @new_resource.web_context_url.nil?
      system_properties['WebContextURL'] = @new_resource.web_context_url
    end

    unless @new_resource.portal_private_url == node.default['arcgis']['portal']['private_url']
      system_properties['privatePortalURL'] = @new_resource.portal_private_url
    end

    portal_admin_client.update_system_properties(system_properties)

    new_resource.updated_by_last_action(true)
  end
end

action :join_site do
  portal_admin_client = ArcGIS::PortalAdminClient.new(
    @new_resource.portal_local_url,
    @new_resource.username,
    @new_resource.password)

  portal_admin_client.wait_until_available

  if portal_admin_client.site_exist?
    Chef::Log.info('Portal site already exists.')
  else
    Chef::Log.info('Joining portal site...')

    portal_admin_client.join_site(@new_resource.primary_machine_url)

    sleep(120.0)

    portal_admin_client.wait_until_available

    new_resource.updated_by_last_action(true)
  end
end

action :configure_https do
  portal_admin_client = ArcGIS::PortalAdminClient.new(@new_resource.portal_url,
                                                      @new_resource.username,
                                                      @new_resource.password)

  cert_alias = portal_admin_client.server_ssl_certificate

  unless cert_alias == @new_resource.cert_alias
    unless portal_admin_client.ssl_certificate_exist?(@new_resource.cert_alias)
      portal_admin_client.import_server_ssl_certificate(
        @new_resource.keystore_file,
        @new_resource.keystore_password,
        @new_resource.cert_alias)
    end

    portal_admin_client.set_server_ssl_certificate(@new_resource.cert_alias)

    sleep(60.0)

    portal_admin_client.wait_until_available

    new_resource.updated_by_last_action(true)
  end
end

action :register_server do
  portal_admin_client = ArcGIS::PortalAdminClient.new(@new_resource.portal_url,
                                                      @new_resource.username,
                                                      @new_resource.password)

  portal_admin_client.wait_until_available

  servers = portal_admin_client.servers

  server = servers.detect { |s| s['url'] == @new_resource.server_url }

  if server.nil?
    server_admin_uri = URI.parse(@new_resource.server_url + '/admin')
    server_name = server_admin_uri.host + ':' + server_admin_uri.port.to_s

    json = portal_admin_client.register_server(server_name,
                                               @new_resource.server_url,
                                               @new_resource.server_admin_url,
                                               @new_resource.is_hosted,
                                               'ArcGIS')

    node.set['arcgis']['server']['server_id'] = json['serverId']
    node.set['arcgis']['server']['secret_key'] = json['secretKey']

    new_resource.updated_by_last_action(true)
  else
    Chef::Log.warn("Server #{@new_resource.server_url} is already registered with portal (#{server['id']}).")
  end
end

action :federate_server do
  portal_admin_client = ArcGIS::PortalAdminClient.new(@new_resource.portal_url,
                                                      @new_resource.username,
                                                      @new_resource.password)
  portal_admin_client.wait_until_available

  servers = portal_admin_client.servers

  server = servers.detect { |s| s['url'] == @new_resource.server_url }

  if server.nil?
    server_admin_client = ArcGIS::ServerAdminClient.new(
      @new_resource.server_admin_url,
      @new_resource.server_username,
      @new_resource.server_password)

    server_admin_client.start_service('Utilities/PrintingTools.GPServer')

    server_id = portal_admin_client.federate_server(
      @new_resource.server_url,
      @new_resource.server_admin_url,
      @new_resource.server_username,
      @new_resource.server_password)

    if @new_resource.is_hosting
      sleep(300.0)
      portal_admin_client.update_server(server_id, 'HOSTING_SERVER')
    end

    new_resource.updated_by_last_action(true)
  end
end

action :stop do
  if node['platform'] == 'windows'
    service 'Portal for ArcGIS' do
      action :stop
    end
  else
    install_dir = node['arcgis']['portal']['install_dir']

    execute 'Stop Portal' do
      command ::File.join(install_dir, 'arcgis/portal/stopportal.sh')
      user node['arcgis']['run_as_user']
    end
  end

  new_resource.updated_by_last_action(true)
end

action :start do
  if node['platform'] == 'windows'
    service 'Portal for ArcGIS' do
      action :start
    end
  else
    install_dir = node['arcgis']['portal']['install_dir']

    execute 'Start Portal' do
      command ::File.join(install_dir, 'arcgis/portal/startportal.sh')
      user node['arcgis']['run_as_user']
    end
  end

  new_resource.updated_by_last_action(true)
end

private

def configure_autostart(portalhome)
  Chef::Log.info('Configure Portal for ArcGIS to be started with the operating system.')

  arcgisportal_path = '/etc/init.d/arcgisportal'

  if ['rhel', 'centos'].include?(node['platform_family'])
    arcgisportal_path = '/etc/rc.d/init.d/arcgisportal'
  end

  template arcgisportal_path do
    source 'arcgisportal.erb'
    variables ({ :portalhome => portalhome })
    owner 'root'
    group 'root'
    mode '0755'
    not_if { ::File.exist?(arcgisportal_path) }
  end

  service 'arcgisportal' do
    supports :status => true, :restart => true, :reload => true
    action [:enable, :restart]
  end
end
