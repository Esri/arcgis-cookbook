#
# Cookbook Name:: arcgis-enterprise
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
require 'json'

if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  require 'win32/service'
end

use_inline_resources if defined?(use_inline_resources)

action :system do
  case node['platform']
  when 'windows'
    # Configure Windows firewall
    windows_firewall_rule 'Portal for ArcGIS' do
      description 'Allows connections through all ports used by Portal for ArcGIS'
      localport '5701,5702,7080,7443,7005,7099,7199,7120,7220,7654'
      dir :in
      protocol 'TCP'
      firewall_action :allow
      only_if { node['arcgis']['configure_windows_firewall'] }
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
    run_as_password = @new_resource.run_as_password.gsub("&", "^&")
    # install_log = ::File.join(Chef::Config[:file_cache_path], 'portal_install.log')
    # /log \"#{install_log}\" 
    args = "/qb INSTALLDIR=\"#{@new_resource.install_dir}\" "\
           "CONTENTDIR=\"#{node['arcgis']['portal']['data_dir']}\" "\
           "USER_NAME=\"#{@new_resource.run_as_user}\" "\
           "PASSWORD=\"#{run_as_password}\""

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 7200 })
    cmd.run_command
    cmd.error!
  else
    cmd = @new_resource.setup
    args = "-m silent -l yes -d \"#{@new_resource.install_dir}\""
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['portal']['install_subdir'])
    dir_data = @new_resource.data_dir
    run_as_user = @new_resource.run_as_user

    subdir = @new_resource.install_dir
    node['arcgis']['portal']['install_subdir'].split("/").each do |path|
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

    if dir_data != node.default['arcgis']['portal']['data_dir']
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
  end

  # Wait for Portal installation to finish
  sleep(900.0)

  new_resource.updated_by_last_action(true)
end

action :uninstall do
  if node['platform'] == 'windows'
    cmd = 'msiexec'
    args = "/qb /x #{@new_resource.product_code}"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", {:timeout => 10800})
    cmd.run_command
    cmd.error!
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['portal']['install_subdir'])
    cmd = ::File.join(install_subdir, 'uninstall_ArcGISPortal')
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

action :configure_autostart do
  if node['platform'] == 'windows'
    service 'Portal for ArcGIS' do
      action :enable
    end
  else
    Chef::Log.info('Configure Portal for ArcGIS to be started with the operating system.')

    agsuser = node['arcgis']['run_as_user']
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['portal']['install_subdir'])

    # SysV
    if node['init_package'] == 'init'
      arcgisportal_path = '/etc/init.d/arcgisportal'
      service_file = 'arcgisportal.erb'
      template_variables = ({ :portalhome => install_subdir })
    # Systemd
    else # node['init_package'] == 'systemd'
      arcgisportal_path = '/etc/systemd/system/arcgisportal.service'
      service_file = 'arcgisportal.service.erb'
      template_variables = ({ :portalhome => install_subdir, :agsuser => agsuser })
      if node['arcgis']['configure_cloud_settings']
        if node['cloud']['provider'] == 'ec2'
          cloudenvironment = { :cloudenvironment => 'Environment="arcgis_cloud_platform=aws"' }
          template_variables = template_variables.merge(cloudenvironment)
        end
      end
    end

    template arcgisportal_path do
      source service_file
      cookbook 'arcgis-enterprise'
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
      notifies :restart, 'service[arcgisportal]', :immediately
    end

    service 'arcgisportal' do
      supports :status => true, :restart => true, :reload => true
      action :enable
    end

    new_resource.updated_by_last_action(true)
  end
end

action :update_account do
  if node['platform'] == 'windows'
    configureserviceaccount = ::File.join(@new_resource.install_dir,
                                          'tools', 'ConfigUtility',
                                          'configureserviceaccount.bat')
    run_as_password = @new_resource.run_as_password.gsub("&", "^&")
    args = "/username \"#{@new_resource.run_as_user}\" "\
           "/password \"#{run_as_password}\""

    cmd = Mixlib::ShellOut.new("cmd.exe /C \"\"#{configureserviceaccount}\" #{args}\"",
                               {:timeout => 3600})
    cmd.run_command
    cmd.error!

    # Update logon account of the windows service directly in addition to running configureserviceaccount.bat
    Utils.sc_config('Portal for ArcGIS', @new_resource.run_as_user, @new_resource.run_as_password)

    new_resource.updated_by_last_action(true)
  end
end

action :authorize do
  portal_admin_client = ArcGIS::PortalAdminClient.new(
    @new_resource.portal_url,
    @new_resource.username,
    @new_resource.password)

  portal_admin_client.wait_until_available

  if portal_admin_client.is_user_type_licensing
    # Validate user type license
    license_info = portal_admin_client.validate_license(@new_resource.authorization_file)

    if license_info['MyEsri']['version'] != @new_resource.authorization_file_version
      throw "Authorization file version '#{license_info['MyEsri']['version']}' does not match ArcGIS version '#{@new_resource.authorization_file_version}'."
    end

    # user_type = license_info['MyEsri']['definitions']['userTypes'].detect { |u| u['id'] == @new_resource.user_license_type_id }

    # if (user_type == nil)
    #   throw "Unrecognized user license type id '#{@new_resource.user_license_type_id}'."
    # end

    # if (user_type['level'] != '2')
    #   throw "The specified user license type id '#{@new_resource.user_license_type_id}' is invalid. The user license type for your Initial Administrator must have Level 2 capabilities."
    # end

    new_resource.updated_by_last_action(false)
  else
    # Authorize Portal
    cmd = node['arcgis']['portal']['authorization_tool']

    if node['platform'] == 'windows'
      args = "/VER #{@new_resource.authorization_file_version} "\
             "/LIF \"#{@new_resource.authorization_file}\" /S"

      cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 600} )
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
end

action :create_site do
  portal_admin_client = ArcGIS::PortalAdminClient.new(
    @new_resource.portal_url,
    @new_resource.username,
    @new_resource.password)

  portal_admin_client.wait_until_available

  # Complete portal upgrade if the upgrade API is available (starting from ArcGIS Enterprise 10.6)
  if portal_admin_client.complete_upgrade(@new_resource.upgrade_backup,
                                          @new_resource.upgrade_rollback,
                                          @new_resource.authorization_file)
    Chef::Log.info('Wait until portal restarted after upgrade.')

    1800.times do
      break if !Utils.url_available?(@new_resource.portal_url + '/portaladmin')
      sleep(1.0)
    end

    portal_admin_client.wait_until_available

    begin
      portal_admin_client.post_upgrade()
    rescue Exception => e
      Chef::Log.error 'Portal post upgrade failed. ' + e.message
    end

    portal_admin_client.wait_until_available

    begin
      portal_admin_client.reindex()
    rescue Exception => e
      Chef::Log.error 'Portal content reindex failed. ' + e.message
    end

    portal_admin_client.wait_until_available

    Chef::Log.info('Upgrade Living Atlas...')
    begin
      portal_admin_client.upgrade_livingatlas(node['arcgis']['portal']['living_atlas']['group_ids'])
    rescue Exception => e
      Chef::Log.error 'Living Atlas upgrade failed. ' + e.message
    end
  end

  portal_admin_client.wait_until_available

  if portal_admin_client.site_exist?
    Chef::Log.info('Portal site already exists.')
  else
    Chef::Log.info('Creating portal site...')

    content_store = {
      'type' => @new_resource.content_store_type,
      'provider' => @new_resource.content_store_provider,
      'connectionString' => @new_resource.content_store_connection_string,
      'objectStore' => @new_resource.object_store
    }

    portal_admin_client.create_site(@new_resource.email,
                                    @new_resource.full_name,
                                    @new_resource.description,
                                    @new_resource.security_question,
                                    @new_resource.security_question_answer,
                                    content_store.to_json,
                                    @new_resource.user_license_type_id,
                                    @new_resource.authorization_file)

    sleep(120.0)

    portal_admin_client.wait_until_available

    portal_admin_client.populate_license

    system_properties = {}

    unless @new_resource.web_context_url.empty?
      system_properties['WebContextURL'] = @new_resource.web_context_url
    end

    unless @new_resource.portal_private_url == node.default['arcgis']['portal']['private_url']
      system_properties['privatePortalURL'] = @new_resource.portal_private_url
    end

    portal_admin_client.update_system_properties(system_properties)

    portal_admin_client.edit_log_settings(@new_resource.log_level,
                                          @new_resource.log_dir,
                                          @new_resource.max_log_file_age)

    unless @new_resource.root_cert.empty? || @new_resource.root_cert_alias.empty?
      portal_admin_client.add_root_cert(@new_resource.root_cert, @new_resource.root_cert_alias, 'false')
    end

    sleep(60.0) # wait for portal restart

    new_resource.updated_by_last_action(true)
  end
end

action :join_site do
  portal_admin_client = ArcGIS::PortalAdminClient.new(
    @new_resource.portal_url,
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

action :set_identity_store do
  begin
    portal_admin_client= ArcGIS::PortalAdminClient.new(@new_resource.portal_url,
                                                 @new_resource.username,
                                                 @new_resource.password)

    portal_admin_client.wait_until_available

    Chef::Log.info('Setting Portal identity stores...')

    portal_admin_client.set_identity_store(@new_resource.user_store_config,@new_resource.role_store_config)

    portal_admin_client.wait_until_available

    new_resource.updated_by_last_action(true)
  rescue Exception => e
    Chef::Log.error "Failed to configure Portal identity stores. " + e.message
    raise e
  end
end

action :unregister_standby do
  portal_admin_client = ArcGIS::PortalAdminClient.new(
    @new_resource.portal_url,
    @new_resource.username,
    @new_resource.password)

  if Utils.url_available?(@new_resource.portal_url + '/portaladmin') &&
     portal_admin_client.site_exist?
    portal_admin_client.machines.each do |machine|
      if machine['role'] == "standby"
        portal_admin_client.unregister_machine(machine['machineName'])

        new_resource.updated_by_last_action(true)
      end
    end
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

action :set_allssl do
  portal_admin_client = ArcGIS::PortalAdminClient.new(@new_resource.portal_url,
                                                      @new_resource.username,
                                                      @new_resource.password)

  portal_admin_client.wait_until_available

  json = portal_admin_client.set_allssl(@new_resource.allssl)

  Chef::Log.info("Result of allssl update: (#{json})")
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
      sleep(180.0)
      portal_admin_client.update_server(server_id, 'HOSTING_SERVER', '')
    end

    new_resource.updated_by_last_action(true)
  end
end

action :enable_server_function do
  portal_admin_client = ArcGIS::PortalAdminClient.new(@new_resource.portal_url,
                                                      @new_resource.username,
                                                      @new_resource.password)

  portal_admin_client.wait_until_available

  if portal_admin_client.site_exist?

    servers = portal_admin_client.servers

    server = servers.detect { |s| s['url'] == @new_resource.server_url }

    if server.nil?
      Chef::Log.info("Server #{@new_resource.server_url} was not federated with the portal")
    else
      Chef::Log.info("Enabling '#{@new_resource.server_function}' on Server (#{server['id']})...")
      server_role = @new_resource.is_hosting ? "HOSTING_SERVER" : "FEDERATED_SERVER"
      result = portal_admin_client.update_server(server['id'], server_role, @new_resource.server_function)
      Chef::Log.info("Result of update: (#{result})")
    end
  else
    Chef::Log.warn("Portal Admin not available")
  end
end

action :stop do
  if node['platform'] == 'windows'
    if ::Win32::Service.status('Portal for ArcGIS').current_state == 'running'
      service 'Portal for ArcGIS' do
        action :stop
      end
      new_resource.updated_by_last_action(true)
    end
  else
    if node['arcgis']['portal']['configure_autostart']
      service 'arcgisportal' do
        supports :status => true, :restart => true, :reload => true
        action :stop
      end
    else
      cmd = node['arcgis']['portal']['stop_tool']

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

action :start do
  if node['platform'] == 'windows'
    if node['arcgis']['configure_cloud_settings']
      if node['cloud']['provider'] == 'ec2'
        env 'arcgis_cloud_platform' do
          value 'aws'
        end
      end
    end

    if ::Win32::Service.status('Portal for ArcGIS').current_state != 'running'
      service 'Portal for ArcGIS' do
        action [:enable, :start]
      end
      new_resource.updated_by_last_action(true)
    end
  else
    tomcat_java_opts = node['arcgis']['portal']['tomcat_java_opts']
    unless (tomcat_java_opts.empty?)
      replace = "indexserver"
      pattern = "#{replace} #{tomcat_java_opts}"
      catalina_file = ::File.join(node['arcgis']['portal']['install_dir'], node['arcgis']['portal']['install_subdir'], '/framework/runtime/tomcat/bin/catalina.sh')
      sed_cmd = "sed -i \"s/#{replace}/#{pattern}/g\" #{catalina_file}"
      sed_cmd = Mixlib::ShellOut.new(sed_cmd, {:timeout => 30})
      sed_cmd.run_command
      sed_cmd.error!
    end

    if node['arcgis']['portal']['configure_autostart']
      service 'arcgisportal' do
        supports :status => true, :restart => true, :reload => true
        action [:enable, :start]
      end
    else
      cmd = node['arcgis']['portal']['start_tool']

      if node['arcgis']['configure_cloud_settings']
        if node['cloud']['provider'] == 'ec2'
          cmd = 'arcgis_cloud_platform=aws ' + cmd
        end
      end

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

action :configure_hostidentifiers_properties do
  template ::File.join(node['arcgis']['portal']['install_dir'],
                       node['arcgis']['portal']['install_subdir'],
                       'framework', 'runtime', 'ds', 'framework', 'etc',
                       'hostidentifier.properties') do
    source 'hostidentifier.properties.erb'
    variables ( {:hostidentifier => node['arcgis']['portal']['hostidentifier'],
                 :preferredidentifier => node['arcgis']['portal']['preferredidentifier']} )
  end
end
