#
# Cookbook Name:: arcgis-server
# Provider:: server
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
#
require 'fileutils'

if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  require 'win32/service'
end

use_inline_resources

action :system do
  case node['platform']
  when 'windows'
    # Install .Net Framework
    if node['platform_version'].to_f < 6.3
      node.default['ms_dotnet']['v4']['version'] = '4.5.1'
      @run_context.include_recipe 'ms_dotnet::ms_dotnet4'
    end
  when 'redhat', 'centos'
    ['fontconfig', 'freetype', 'gettext', 'libxkbfile', 'libXtst', 'libXrender', 'dos2unix'].each do |pckg|
      yum_package @new_resource.recipe_name + ':server:' + pckg do
        options '--enablerepo=*-optional'
        package_name pckg
        action :install
      end
    end
  when 'suse'
    ['libGLU1', 'libXdmcp6', 'xorg-x11-server', 'libXfont1'].each do |pckg|
      package @new_resource.recipe_name + ':server:' + pckg do
        package_name pckg
        action :install
      end
    end
  else
    # NOTE: ArcGIS products are not officially supported on debian linux family
    ['xserver-common', 'xvfb', 'libfreetype6', 'libfontconfig1', 'libxfont1',
     'libpixman-1-0', 'libgl1-mesa-dri', 'libgl1-mesa-glx', 'libglu1-mesa',
     'libpng12-0', 'x11-xkb-utils', 'libapr1', 'libxrender1', 'libxi6',
     'libxtst6', 'libaio1', 'nfs-kernel-server', 'autofs',
     'libxkbfile1'].each do |pckg|
      package @new_resource.recipe_name + ':server:' + pckg do
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
    args = "/qb INSTALLDIR=\"#{@new_resource.install_dir}\" INSTALLDIR1=\"#{@new_resource.python_dir}\" USER_NAME=\"#{@new_resource.run_as_user}\" PASSWORD=\"#{@new_resource.run_as_password}\""

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 7200 })
    cmd.run_command
    cmd.error!
  else
    cmd = @new_resource.setup
    args = "-m silent -l yes -d \"#{@new_resource.install_dir}\""
    run_as_user = @new_resource.run_as_user

    subdir = @new_resource.install_dir
    node['arcgis']['server']['install_subdir'].split("/").each do |path|
      subdir = ::File.join(subdir, path)
      FileUtils.mkdir_p(subdir) unless ::File.directory?(subdir)
      FileUtils.chmod 0700, subdir
      FileUtils.chown run_as_user, nil, subdir
    end

    if node['arcgis']['run_as_superuser']
      cmd = Mixlib::ShellOut.new("su #{run_as_user} -c \"#{cmd} #{args}\"", { :timeout => 7200 })
    else
      cmd = Mixlib::ShellOut.new("#{cmd} #{args}", {:user => run_as_user, :timeout => 7200})
    end
    cmd.run_command
    cmd.error!
  end

  # Wait for Server installation to finish
  sleep(180.0)

  new_resource.updated_by_last_action(true)
end

action :uninstall do
  if node['platform'] == 'windows'
    cmd = 'msiexec'
    args = "/qb /x #{@new_resource.product_code}"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", {:timeout => 3600})
    cmd.run_command
    cmd.error!
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['server']['install_subdir'])
    cmd = ::File.join(install_subdir, 'uninstall_ArcGISServer')
    args = '-s'
    run_as_user = @new_resource.run_as_user

    if node['arcgis']['run_as_superuser']
      cmd = Mixlib::ShellOut.new("su #{run_as_user} -c \"#{cmd} #{args}\"", { :timeout => 3600 })
    else
      cmd = Mixlib::ShellOut.new("#{cmd} #{args}", {:user => run_as_user, :timeout => 3600})
    end
    cmd.run_command
    cmd.error!
  end

  new_resource.updated_by_last_action(true)
end

action :update_account do
  if node['platform'] == 'windows'
    service_name = 'ArcGIS Server'
    run_as_user = @new_resource.run_as_user
    run_as_password = @new_resource.run_as_password
    if run_as_user.include? '\\'
      service_logon_user = run_as_user
    else
      service_logon_user = ".\\#{run_as_user}"
    end

    Utils.retry_ShellOut("net stop \"#{service_name}\" /yes", 5, 60, {:timeout => 600})
    Utils.retry_ShellOut("sc.exe config \"#{service_name}\" obj= \"#{service_logon_user}\" password= \"#{run_as_password}\"",
                         1, 60, {:timeout => 600})
    Utils.retry_ShellOut("net start \"#{service_name}\" /yes", 5, 60, {:timeout => 600})

    sleep(120.0)

    new_resource.updated_by_last_action(true)
  end
end

action :authorize do
  cmd = node['arcgis']['server']['authorization_tool']

  if node['platform'] == 'windows'
    args = "/VER #{@new_resource.authorization_file_version} /LIF \"#{@new_resource.authorization_file}\" /S"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", {:timeout => 600})
    cmd.run_command
    cmd.error!
  else
    args = "-f \"#{@new_resource.authorization_file}\""

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
          { :user => node['arcgis']['run_as_user'], :timeout => 600 })
    cmd.run_command
    cmd.error!
  end

  new_resource.updated_by_last_action(true)
end

action :create_site do
  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

  admin_client.wait_until_available

  if admin_client.site_exist?
    Chef::Log.warn('ArcGIS Server site already exists.')
  else
    Chef::Log.info('Creating ArcGIS Server site...')

    admin_client.create_site(@new_resource.server_directories_root,
                             @new_resource.config_store_type,
                             @new_resource.config_store_connection_string,
                             @new_resource.config_store_connection_secret,
                             @new_resource.log_level)

    admin_client.wait_until_available

    if !@new_resource.system_properties.empty?
      Chef::Log.info('Updating ArcGIS Server system properties...')
      sleep(120.0)
      admin_client.update_system_properties(@new_resource.system_properties)
    end

    new_resource.updated_by_last_action(true)
  end
end

action :join_site do
  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

  admin_client.wait_until_available

  if admin_client.site_exist?
    Chef::Log.warn('Machine is already connected to an ArcGIS Server site.')
  else
    primary_admin_client = ArcGIS::ServerAdminClient.new(
      @new_resource.primary_server_url,
      @new_resource.username,
      @new_resource.password)

    primary_admin_client.wait_until_site_exist

    admin_client.join_site(@new_resource.primary_server_url)

    new_resource.updated_by_last_action(true)
  end
end

action :join_cluster do
  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

  admin_client.wait_until_available

  machine_name = admin_client.local_machine_name

  admin_client.add_machine_to_cluster(machine_name, @new_resource.cluster)

  new_resource.updated_by_last_action(true)
end

action :configure_https do
  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

  machine_name = admin_client.local_machine_name

  cert_alias = admin_client.get_server_ssl_certificate(machine_name)

  unless cert_alias == @new_resource.cert_alias
    unless admin_client.ssl_certificate_exist?(machine_name, @new_resource.cert_alias)
      admin_client.import_server_ssl_certificate(machine_name,
                                                 @new_resource.keystore_file,
                                                 @new_resource.keystore_password,
                                                 @new_resource.cert_alias)
    end

    admin_client.set_server_ssl_certificate(machine_name, @new_resource.cert_alias)

    sleep(60.0)

    admin_client.wait_until_available

    new_resource.updated_by_last_action(true)
  end
end

action :register_database do
  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                               @new_resource.username,
                                               @new_resource.password)

  admin_client.register_database(@new_resource.data_item_path,
                                 @new_resource.connection_string,
                                 @new_resource.is_managed)

  new_resource.updated_by_last_action(true)
end

action :federate do
  server_id = @new_resource.server_id
  secret_key = @new_resource.secret_key

  server_id = node['arcgis']['server']['server_id'] if server_id.nil?

  secret_key = node['arcgis']['server']['secret_key'] if secret_key.nil?

  if !server_id.nil? && !secret_key.nil?
    portal_admin_client = ArcGIS::PortalAdminClient.new(
      @new_resource.portal_url,
      @new_resource.portal_username,
      @new_resource.portal_password)

    portal_admin_client.wait_until_available

    portal_token = portal_admin_client.generate_token(
      @new_resource.portal_url + '/sharing/generateToken')

    server_admin_client = ArcGIS::ServerAdminClient.new(
      @new_resource.server_url,
      @new_resource.username,
      @new_resource.password)

    server_admin_client.wait_until_available

    server_admin_client.federate(@new_resource.portal_url,
                                 portal_token,
                                 server_id,
                                 secret_key)

    new_resource.updated_by_last_action(true)
  end
end

action :stop do
  if node['platform'] == 'windows'
    if ::Win32::Service.status('ArcGIS Server').current_state == 'running'
      #Stop ArcGIS Server windows service and dependent services.
      Utils.retry_ShellOut("net stop \"ArcGIS Server\" /yes",
                           5, 60, {:timeout => 3600})
      new_resource.updated_by_last_action(true)
    end
  else
    if node['arcgis']['server']['configure_autostart']
      service 'arcgisserver' do
        supports :status => true, :restart => true, :reload => true
        action :stop
      end
    else
      cmd = node['arcgis']['server']['stop_tool']

      if node['arcgis']['run_as_superuser']
        cmd = Mixlib::ShellOut.new("su #{node['arcgis']['run_as_user']} -c \"#{cmd}\"", {:timeout => 30})
      else
        cmd = Mixlib::ShellOut.new(cmd, {:timeout => 30})
      end
      cmd.run_command
      cmd.error!
      new_resource.updated_by_last_action(true)
    end
  end
end

action :start do
  if node['platform'] == 'windows'
    if ::Win32::Service.status('ArcGIS Server').current_state != 'running'
      #Start ArcGIS Server windows service and dependent services.
      Utils.retry_ShellOut("net start \"ArcGIS Server\" /yes", 5, 60, {:timeout => 600})
      new_resource.updated_by_last_action(true)
    end
  else
    if node['arcgis']['server']['configure_autostart']
      service 'arcgisserver' do
        supports :status => true, :restart => true, :reload => true
        action [:enable, :start]
      end
    else
      cmd = node['arcgis']['server']['start_tool']

      if node['arcgis']['run_as_superuser']
        cmd = Mixlib::ShellOut.new("su #{node['arcgis']['run_as_user']} -c \"#{cmd}\"", {:timeout => 30})
      else
        cmd = Mixlib::ShellOut.new(cmd, {:timeout => 30})
      end
      cmd.run_command
      cmd.error!
    end
    new_resource.updated_by_last_action(true)
  end
end

action :configure_autostart do
  if node['platform'] == 'windows'
    service 'ArcGIS Server' do
      action :enable
    end
  else
    Chef::Log.info('Configure ArcGIS for Server to be started with the operating system.')
    agsuser = node['arcgis']['run_as_user']
    agshome = ::File.join(@new_resource.install_dir,
                          node['arcgis']['server']['install_subdir'])

    # SysV
    if node['init_package'] == 'init'
      arcgisserver_path = '/etc/init.d/arcgisserver'
      service_file = 'arcgisserver.erb'
      template_variables = ({ :agshome => agshome })
    # Systemd
    else node['init_package'] == 'systemd'
      arcgisserver_path = '/etc/systemd/system/arcgisserver.service'
      service_file = 'arcgisserver.service.erb'
      template_variables = ({ :agshome => agshome, :agsuser => agsuser })
    end

    template arcgisserver_path do
      source service_file
      cookbook 'arcgis-server'
      variables template_variables
      owner 'root'
      group 'root'
      mode '0755'
      notifies :run, 'execute[Load systemd unit file]', :immediately
    end

    execute 'Load systemd unit file' do
      command 'systemctl daemon-reload'
      action :nothing
      only_if {( node['init_package'] == 'systemd' )}
      notifies :restart, 'service[arcgisserver]', :immediately
    end

    service 'arcgisserver' do
      supports :status => true, :restart => true, :reload => true
      action :enable
    end

    new_resource.updated_by_last_action(true)
  end
end
