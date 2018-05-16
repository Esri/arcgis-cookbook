#
# Cookbook Name:: arcgis-enterprise
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
require 'json'

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

    # Configure Windows firewall

    windows_firewall_rule 'ArcGIS Server' do
      description 'Allows connections through all ports used by ArcGIS Server'
      localport '1098,4000-4004,6006,6080,6099,6443'
      dir :in
      protocol 'TCP'
      firewall_action :allow
      only_if { node['arcgis']['configure_windows_firewall'] }
    end

    windows_firewall_rule 'ArcGIS GeoAnalytics Server' do
      description 'Allows connections through all ports used by ArcGIS GeoAnalytics Server'
      localport '2181,2182,2190,7077,56540-56545'
      dir :in
      protocol 'TCP'
      firewall_action :allow
      only_if { node['arcgis']['configure_windows_firewall'] }
    end

#    windows_firewall_rule 'ArcGIS Server - Javaw' do
#      description 'For ArcGIS server to be able to make a cluster, connecting to other machines, Allow outbound connections for javaw.exe'
#      program node['arcgis']['server']['install_dir'] + '\\framework\\runtime\\jre\\bin\\javaw.exe'
#      dir :out
#      firewall_action :allow
#      only_if { node['arcgis']['configure_windows_firewall'] }
#    end
#
#    windows_firewall_rule 'ArcGIS Server - Java' do
#      description 'For ArcGIS server to be able to make a cluster, connecting to other machines, Allow outbound connections for java.exe'
#      program node['arcgis']['server']['install_dir'] + '\\framework\\runtime\\jre\\bin\\java.exe'
#      dir :out
#      firewall_action :allow
#      only_if { node['arcgis']['configure_windows_firewall'] }
#    end
#
#    windows_firewall_rule 'ArcGIS Server - NodeAgent' do
#      description 'Allow ArcGISServer NodeAgent'
#      program node['arcgis']['server']['install_dir'] + '\\framework\\etc\\service\\bin\\ArcGISServer.exe'
#      dir :out
#      firewall_action :allow
#      only_if { node['arcgis']['configure_windows_firewall'] }
#    end
#
#    windows_firewall_rule 'ArcGIS Server - rmid' do
#      description 'Allow remote message invocation (communication between processes)'
#      program node['arcgis']['server']['install_dir'] + '\\framework\\runtime\\jre\\bin\\rmid.exe'
#      dir :out
#      firewall_action :allow
#      only_if { node['arcgis']['configure_windows_firewall'] }
#    end
#
#    windows_firewall_rule 'ArcGIS Server - ConHost' do
#      description 'Allow console process used by java.exe'
#      program '%SystemRoot%\\System32\\conhost.exe'
#      dir :out
#      firewall_action :allow
#      only_if { node['arcgis']['configure_windows_firewall'] }
#    end
#
#    windows_firewall_rule 'ArcGIS Server - ServerConfigurationUtility' do
#      description 'Allow ServerConfigurationUtility to make outbound connections'
#      program node['arcgis']['server']['install_dir'] + '\\bin\\ServerConfigurationUtility.exe'
#      dir :out
#      firewall_action :allow
#      only_if { node['arcgis']['configure_windows_firewall'] }
#    end
#
#    windows_firewall_rule 'ArcGIS Server - ServerConfigurationUtilityUI' do
#      description 'Allow ServerConfigurationUtilityUI to make outbound connections'
#      program node['arcgis']['server']['install_dir'] + '\\bin\\ServerConfigurationUtilityUI.exe'
#      dir :out
#      firewall_action :allow
#      only_if { node['arcgis']['configure_windows_firewall'] }
#    end
#
#    windows_firewall_rule 'ArcGIS Server - ArcSOC' do
#      description 'Allow ArcSOC to make outbound connections'
#      program node['arcgis']['server']['install_dir'] + '\\bin\\ArcSOC.exe'
#      dir :out
#      firewall_action :allow
#      only_if { node['arcgis']['configure_windows_firewall'] }
#    end
#
#    windows_firewall_rule 'ArcGIS Server - DataLicInstall' do
#      description 'Allow DataLicInstall to make outbound connections'
#      program node['arcgis']['server']['install_dir'] + '\\bin\\DataLicInstall.exe'
#      dir :out
#      firewall_action :allow
#      only_if { node['arcgis']['configure_windows_firewall'] }
#    end
#
#    windows_firewall_rule 'ArcGIS - ArcGISConnection' do
#      description 'Allow ArcGISConnection to make outbound connections'
#      program ENV['CommonProgramFiles'] + '\\ArcGIS\\bin\\ArcGISConnection.exe'
#      dir :out
#      firewall_action :allow
#      only_if { node['arcgis']['configure_windows_firewall'] }
#    end
#
#    windows_firewall_rule 'ArcGIS - ESRIRegAsm' do
#      description 'Allow ESRIRegAsm to make outbound connections'
#      program ENV['CommonProgramFiles'] + '\\ArcGIS\\bin\\ESRIRegAsm.exe'
#      dir :out
#      firewall_action :allow
#      only_if { node['arcgis']['configure_windows_firewall'] }
#    end
#
#    windows_firewall_rule 'ArcGIS - ESRIReporter' do
#      description 'Allow ESRIReporter to make outbound connections'
#      program ENV['CommonProgramFiles'] + '\\ArcGIS\\bin\\ESRIReporter.exe'
#      dir :out
#      firewall_action :allow
#      only_if { node['arcgis']['configure_windows_firewall'] }
#    end
#
#    windows_firewall_rule 'ArcGIS - ESRIWebReporter' do
#      description 'Allow ESRIWebReporter to make outbound connections'
#      program ENV['CommonProgramFiles'] + '\\ArcGIS\\bin\\ESRIWebReporter.exe'
#      dir :out
#      firewall_action :allow
#      only_if { node['arcgis']['configure_windows_firewall'] }
#    end
#
#    windows_firewall_rule 'ArcGIS - SoftwareAuthorization' do
#      description 'Allow SoftwareAuthorization to make outbound connections'
#      program ENV['CommonProgramFiles'] + '\\ArcGIS\\bin\\SoftwareAuthorization.exe'
#      dir :out
#      firewall_action :allow
#      only_if { node['arcgis']['configure_windows_firewall'] }
#    end
#
#    windows_firewall_rule 'ArcGIS Server - fontSupport' do
#      description 'Allow fontSupport to make outbound connections'
#      program ENV['CommonProgramFiles'] + '\\ArcGIS\\bin\\fontSupport.exe'
#      dir :out
#      firewall_action :allow
#      only_if { node['arcgis']['configure_windows_firewall'] }
#    end
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
    ['xserver-common', 'xvfb', 'libfreetype6', 'fontconfig', 'libxfont1',
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

action :unpack do
  if node['platform'] == 'windows'
    cmd = @new_resource.setup_archive
    args = "/s /d \"#{@new_resource.setups_repo}\""
    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600 })
    cmd.run_command
    cmd.error!
  else
    cmd = 'tar'
    args = "xzvf \"#{@new_resource.setup_archive}\""
    repo = ::File.join(@new_resource.setups_repo, node['arcgis']['version'])
    FileUtils.mkdir_p(repo) unless ::File.directory?(repo)
    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600, :cwd => repo })
    cmd.run_command
    cmd.error!

    FileUtils.chown_R @new_resource.run_as_user, nil, repo
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
    configureserviceaccount = ::File.join(@new_resource.install_dir,
                                          'bin', 'ServerConfigurationUtility.exe')

    args = "/username #{@new_resource.run_as_user} "\
           "/password \"#{@new_resource.run_as_password}\""

    cmd = Mixlib::ShellOut.new("\"#{configureserviceaccount}\" #{args}",
                               {:timeout => 3600})
    cmd.run_command
    cmd.error!

    # Chef::Log.info "ServerConfigurationUtility.exe output: #{cmd.stdout}"

    # Update logon account of the windows service directly in addition to running ServerConfigurationUtility.exe
    Utils.sc_config('ArcGIS Server', @new_resource.run_as_user, @new_resource.run_as_password)

    new_resource.updated_by_last_action(true)
  end
end

action :authorize do
  cmd = node['arcgis']['server']['authorization_tool']
  if node['platform'] == 'windows'
    args = "/VER #{@new_resource.authorization_file_version} /LIF \"#{@new_resource.authorization_file}\" /S"
    sa_cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", {:timeout => 600})
    sleep(rand(0..120)) # Use random delay top reduce probability of multiple machines authorization at the same time 
    sa_cmd.run_command

    # Retry authorization five times with random intervals between 120 and 300 seconds.
    # Check if 'keycodes' file exists after each retry.
    # This is required to get around the problem with simultaneous authorization from 
    # multiple machines using the same license.
    node['arcgis']['server']['authorization_retries'].times do
      if sa_cmd.error?
        Chef::Log.error sa_cmd.format_for_exception + ' Retrying software authorization.'
        sleep(rand(120..300))
      else
        sleep(30)
        break if ::File.exists?(node['arcgis']['server']['keycodes'])
        Chef::Log.error "'#{node['arcgis']['server']['keycodes']}' file not found. Retrying software authorization."
        sleep(rand(90..270))
      end
      sa_cmd.run_command
    end

    sa_cmd.error!
  else
    sa_cmd = Mixlib::ShellOut.new("\"#{cmd}\" -f \"#{@new_resource.authorization_file}\"",
          { :user => node['arcgis']['run_as_user'], :timeout => 600 })
    sleep(rand(0..120)) # Use random delay top reduce probability of multiple machines authorization at the same time
    sa_cmd.run_command

    # Retry authorization five times with random intervals between 120 and 300 seconds.
    # Check if softwareAuthorization stdout does not contain 'Not Authorized' after each retry.
    # This is required to get around the problem with simultaneous authorization from 
    # multiple machines using the same license.
    sa_status_cmd = Mixlib::ShellOut.new("\"#{cmd}\" -s",
          { :user => node['arcgis']['run_as_user'], :timeout => 600 })

    node['arcgis']['server']['authorization_retries'].times do
      if sa_cmd.error?
        Chef::Log.error format_for_exception + '  Retrying software authorization...'
        sleep(rand(120..300))
      else
        sleep(30)
        sa_status_cmd.run_command
        break if !sa_status_cmd.error? && !sa_status_cmd.stdout.include?('Not Authorized')
        Chef::Log.error sa_status_cmd.stdout
        Chef::Log.error "ArcGIS Server is not authorized. Retrying software authorization..."
        sleep(rand(90..270))
      end
      sa_cmd.run_command
    end

    sa_cmd.error!
  end

  new_resource.updated_by_last_action(true)
end

action :create_site do
  begin
    admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                                 @new_resource.username,
                                                 @new_resource.password)
  
    admin_client.wait_until_available

    admin_client.complete_upgrade if admin_client.upgrade_required?

    if admin_client.site_exist?
      Chef::Log.warn('ArcGIS Server site already exists.')
    else
      Chef::Log.info('Creating ArcGIS Server site...')

      admin_client.create_site(@new_resource.server_directories_root,
                               @new_resource.config_store_type,
                               @new_resource.config_store_connection_string,
                               @new_resource.config_store_connection_secret,
                               @new_resource.log_level,
                               @new_resource.log_dir,
                               @new_resource.max_log_file_age)
  
      admin_client.wait_until_available

      #Restart ArcGIS Server on Linux to make sure the server machine SSL certificate is updated
#      if node['platform'] != 'windows' && node['arcgis']['server']['configure_autostart']
#        service 'arcgisserver' do
#          action :restart
#        end
#
#        admin_client.wait_until_available
#      end

      if !@new_resource.system_properties.empty?
        Chef::Log.info('Updating ArcGIS Server system properties...')
        sleep(120.0)
        admin_client.update_system_properties(@new_resource.system_properties)
      end
  
      new_resource.updated_by_last_action(true)
    end
  rescue Exception => e
    Chef::Log.error "Failed to create ArcGIS Server site. " + e.message
    raise e
  end
end

action :join_site do
  begin
    admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                                 @new_resource.username,
                                                 @new_resource.password)
  
    admin_client.wait_until_available
  
    admin_client.complete_upgrade if admin_client.upgrade_required?

    if admin_client.site_exist?
      Chef::Log.warn('Machine is already connected to an ArcGIS Server site.')
    else
      if @new_resource.use_join_site_tool
        config_store_connection = {
          'type' => @new_resource.config_store_type,
          'connectionString' => @new_resource.config_store_connection_string,
          'connectionSecret' => @new_resource.config_store_connection_secret
        }
  
        if node['platform'] == 'windows'
          config_store_connection_file = ::File.join(@new_resource.install_dir, 'framework','etc','config-store-connection.json')
          ::File.open(config_store_connection_file, 'w') { |f| f.write(config_store_connection.to_json) }
  
          join_site_tool_cmd = [
            '"' + ::File.join(@new_resource.install_dir, 'tools', 'JoinSite', 'join-site.bat') + '"',
            '-f', '"' + config_store_connection_file + '"', '-c', 'default'].join(' ')
  
          cmd = Mixlib::ShellOut.new(join_site_tool_cmd, 
            { :user => node['arcgis']['run_as_user'],
              :password => node['arcgis']['run_as_password'],
              :timeout => 1800 })
          cmd.run_command
          cmd.error!
        else
          install_dir = ::File.join(@new_resource.install_dir, node['arcgis']['server']['install_subdir'])
    
          config_store_connection_file = ::File.join(install_dir, 'framework','etc','config-store-connection.json')
          ::File.open(config_store_connection_file, 'w') { |f| f.write(config_store_connection.to_json) }
  
          join_site_tool_cmd = [
            ::File.join(install_dir, 'tools','joinsite','join-site.sh'),
            '-f', config_store_connection_file, '-c', 'default'].join(' ')
  
          cmd = Mixlib::ShellOut.new(join_site_tool_cmd,
                { :user => node['arcgis']['run_as_user'], 
                  :timeout => 1800 })
          cmd.run_command
          cmd.error!
        end
      else
        primary_admin_client = ArcGIS::ServerAdminClient.new(
          @new_resource.primary_server_url,
          @new_resource.username,
          @new_resource.password)
  
        primary_admin_client.wait_until_site_exist
  
        admin_client.join_site(@new_resource.primary_server_url)
      end
  
      new_resource.updated_by_last_action(true)
    end
  rescue Exception => e
    Chef::Log.error "Failed to join ArcGIS Server site. " + e.message
    raise e
  end
end

action :join_cluster do
  begin
    admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                                 @new_resource.username,
                                                 @new_resource.password)
  
    admin_client.wait_until_available
  
    machine_name = admin_client.local_machine_name
  
    admin_client.add_machine_to_cluster(machine_name, @new_resource.cluster)
  
    new_resource.updated_by_last_action(true)
  rescue Exception => e
    Chef::Log.error "Failed to join ArcGIS Server cluster. " + e.message
    raise e
  end
end

action :configure_https do
  begin
    if @new_resource.use_join_site_tool
      token = generate_admin_token(@new_resource.install_dir, 5)

      admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                                   nil, nil, token)
    else
      admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                                   @new_resource.username,
                                                   @new_resource.password)
    end

    machine_name = admin_client.local_machine_name

    cert_alias = admin_client.get_server_ssl_certificate(machine_name)

    unless cert_alias == @new_resource.cert_alias
      unless admin_client.ssl_certificate_exist?(machine_name, @new_resource.cert_alias)
        admin_client.import_server_ssl_certificate(machine_name,
                                                   @new_resource.keystore_file,
                                                   @new_resource.keystore_password,
                                                   @new_resource.cert_alias)
      end

      admin_client.set_server_admin_url(machine_name, @new_resource.server_admin_url)
      admin_client.set_server_ssl_certificate(machine_name, @new_resource.cert_alias)

      sleep(60.0)

      admin_client.wait_until_available

      new_resource.updated_by_last_action(true)
    end
  rescue Exception => e
    Chef::Log.error "Failed to configure SSL certificates in ArcGIS Server. " + e.message
    raise e
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
        cmd = Mixlib::ShellOut.new("su #{node['arcgis']['run_as_user']} -c \"#{cmd}\"", {:timeout => 120})
      else
        cmd = Mixlib::ShellOut.new(cmd, {:timeout => 120})
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
    Chef::Log.info('Configure ArcGIS Server to be started with the operating system.')
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
      cookbook 'arcgis-enterprise'
      variables template_variables
      owner 'root'
      group 'root'
      mode '0755'
      notifies :run, 'execute[Load systemd unit file]', :immediately
      not_if { ::File.exists?(arcgisserver_path) }
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
      retries 5
      retry_delay 60
    end

    new_resource.updated_by_last_action(true)
  end
end

action :set_identity_store do
  begin
    admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                                 @new_resource.username,
                                                 @new_resource.password)

    admin_client.wait_until_available

    Chef::Log.info('Setting ArcGIS Server identity stores...')

    admin_client.set_identity_store(@new_resource.user_store_config,
                                     @new_resource.role_store_config)

    admin_client.wait_until_available

    new_resource.updated_by_last_action(true)
  rescue Exception => e
    Chef::Log.error "Failed to configure ArcGIS Server identity stores. " + e.message
    raise e
  end
end

action :assign_privileges do
  begin
    admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                                 @new_resource.username,
                                                 @new_resource.password)

    admin_client.wait_until_available

    Chef::Log.info('Assigning privileges to user roles...')

    @new_resource.privileges.keys.each do |privilege|
      @new_resource.privileges[privilege].each do |role|
        admin_client.assign_privileges(role, privilege)
      end
    end

    admin_client.wait_until_available

    new_resource.updated_by_last_action(true)
  rescue Exception => e
    Chef::Log.error "Failed to assign privilege to user role. " + e.message
    raise e
  end
end

action :set_machine_properties do
  begin
    if @new_resource.use_join_site_tool
      token = generate_admin_token(@new_resource.install_dir, 5)

      admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                                   nil, nil, token)
    else
      admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url,
                                                   @new_resource.username,
                                                   @new_resource.password)
    end

    admin_client.wait_until_available

    Chef::Log.info('Setting server machine properties...')

    machine_name = admin_client.local_machine_name

    updated = admin_client.set_machine_properties(machine_name, @new_resource.soc_max_heap_size)

    admin_client.wait_until_available

    new_resource.updated_by_last_action(updated)
  rescue Exception => e
    Chef::Log.error "Failed to set server machine properties. " + e.message
    raise e
  end
end

private

def generate_admin_token(install_dir, expiration)
  if node['platform'] == 'windows'
    generate_admin_token_cmd = [
      '"' + ::File.join(install_dir, 'tools', 'GenerateAdminToken', 'generate-admin-token.bat') + '"',
      '-e', expiration.to_s].join(' ')

    cmd = Mixlib::ShellOut.new(generate_admin_token_cmd, 
      { :user => node['arcgis']['run_as_user'],
        :password => node['arcgis']['run_as_password'],
        :timeout => 1800 })
    cmd.run_command
    cmd.error!

    JSON.parse(cmd.stdout)['token']
  else
    install_dir = ::File.join(install_dir, node['arcgis']['server']['install_subdir'])

    generate_admin_token_cmd = [
      ::File.join(install_dir, 'tools','generateadmintoken','generate-admin-token.sh'),
      '-e', expiration.to_s].join(' ')

    cmd = Mixlib::ShellOut.new(generate_admin_token_cmd,
          { :user => node['arcgis']['run_as_user'], 
            :timeout => 1800 })
    cmd.run_command
    cmd.error!

    JSON.parse(cmd.stdout)['token']
  end
end

