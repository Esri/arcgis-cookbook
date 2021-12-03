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
      local_port node['arcgis']['portal']['ports']
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
  unless ::File.exists?(@new_resource.setup)
    raise "File '#{@new_resource.setup}' not found."
  end

  if node['platform'] == 'windows'
    cmd = @new_resource.setup

    password = if @new_resource.run_as_msa
                 'MSA=\"True\"'
               else
                 "PASSWORD=\"#{@new_resource.run_as_password}\""
               end

    args = "/qn ACCEPTEULA=Yes INSTALLDIR=\"#{@new_resource.install_dir}\" "\
           "CONTENTDIR=\"#{node['arcgis']['portal']['data_dir']}\" "\
           "USER_NAME=\"#{@new_resource.run_as_user}\" "\
           "#{password} "\
           "#{@new_resource.setup_options}"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 28800 })
    cmd.run_command
    cmd.error!
  else
    cmd = @new_resource.setup
    args = "-m silent -l yes -d \"#{@new_resource.install_dir}\" #{@new_resource.setup_options}"
    run_as_user = @new_resource.run_as_user
    subdir = @new_resource.install_dir

    node['arcgis']['portal']['install_subdir'].split("/").each do |path|
      subdir = ::File.join(subdir, path)
      FileUtils.mkdir_p(subdir) unless ::File.directory?(subdir)
      FileUtils.chmod 0700, subdir
      FileUtils.chown run_as_user, nil, subdir
    end

    if node['arcgis']['run_as_superuser']
      cmd = Mixlib::ShellOut.new("su #{run_as_user} -c \"#{cmd} #{args}\"", { :timeout => 28800 })
    else
      cmd = Mixlib::ShellOut.new("#{cmd} #{args}", {:user => run_as_user, :timeout => 28800})
    end
    cmd.run_command
    cmd.error!

    # if dir_data != node.default['arcgis']['portal']['data_dir']
    #   properties_filename = ::File.join(install_subdir,
    #                                     'framework', 'etc',
    #                                     'portal-config.properties')

    #   if ::File.exist?(properties_filename)
    #     file = Chef::Util::FileEdit.new(properties_filename)
    #     file.search_file_replace_line(/dir.data.*/, "dir.data=#{dir_data}")
    #     file.write_file
    #   else
    #     ::File.open(properties_filename, 'w') { |f| f.write("dir.data=#{dir_data}") }
    #     FileUtils.chmod(0755, properties_filename)
    #     FileUtils.chown(run_as_user, nil, properties_filename)
    #   end
    # end

    # Stop Portal to start it later using SystemD service
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

action :uninstall do
  if node['platform'] == 'windows'
    cmd = 'msiexec'
    args = "/qn /x #{@new_resource.product_code}"

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
        if node['arcgis']['cloud']['provider'] == 'ec2'
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
  unless ::File.exists?(@new_resource.authorization_file)
    raise "File '#{@new_resource.authorization_file}' not found."
  end

  portal_admin_client = ArcGIS::PortalAdminClient.new(
    @new_resource.portal_url,
    @new_resource.username,
    @new_resource.password)

  portal_admin_client.wait_until_available

  if portal_admin_client.is_user_type_licensing
    # Validate user type license
    license_info = portal_admin_client.validate_license(@new_resource.authorization_file)

    # if license_info['MyEsri']['version'] != @new_resource.authorization_file_version
    #   throw "Authorization file version '#{license_info['MyEsri']['version']}' does not match ArcGIS version '#{@new_resource.authorization_file_version}'."
    # end

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
      raise e
    end

    # portal_admin_client.wait_until_available

    # begin
    #   portal_admin_client.reindex()
    # rescue Exception => e
    #   Chef::Log.error 'Portal content reindex failed. ' + e.message
    # end

    # Wait for portal to restart after post upgrade
    sleep(60.0)

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

    begin
      portal_admin_client.populate_license
    rescue Exception => e
      Chef::Log.error 'Populate license failed. ' + e.message
    end

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

action :set_system_properties do
  portal_admin_client = ArcGIS::PortalAdminClient.new(
    @new_resource.portal_url,
    @new_resource.username,
    @new_resource.password)

  portal_admin_client.wait_until_available

  if portal_admin_client.system_properties != @new_resource.system_properties
    Chef::Log.info 'Setting the portal system properties...'
    portal_admin_client.update_system_properties(@new_resource.system_properties)
    Chef::Log.info 'Portal system properties were updated.'
  else
    Chef::Log.info 'Portal system properties were not changed.'
  end

  portal_admin_client.edit_log_settings(@new_resource.log_level,
                                        @new_resource.log_dir,
                                        @new_resource.max_log_file_age)

  new_resource.updated_by_last_action(true)
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

    sleep(60.0) # wait for portal restart

    portal_admin_client.wait_until_available

    new_resource.updated_by_last_action(true)
  end
end

action :import_root_cert do
  unless @new_resource.root_cert.empty? || @new_resource.root_cert_alias.empty?
    portal_admin_client = ArcGIS::PortalAdminClient.new(@new_resource.portal_url,
                                                        @new_resource.username,
                                                        @new_resource.password)

    unless portal_admin_client.ssl_certificate_exist?(@new_resource.root_cert_alias)
      portal_admin_client.add_root_cert(@new_resource.root_cert,
                                        @new_resource.root_cert_alias, 'false')

      sleep(60.0) # wait for portal restart

      portal_admin_client.wait_until_available

      new_resource.updated_by_last_action(true)
    end
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

  server_admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_admin_url,
                                                      @new_resource.server_username,
                                                      @new_resource.server_password)

  # Wait until Portal admin URL is available.
  portal_admin_client.wait_until_available(5)

  # Wait until Server admin URL is available.
  server_admin_client.wait_until_available(5)

  # Wait until Server web context health check URL is available.
  Utils.wait_until_url_available(@new_resource.server_url + '/rest/info/healthcheck?f=json')

  servers = portal_admin_client.servers

  server = servers.detect { |s| s['url'] == @new_resource.server_url }

  if server.nil?
    portal_admin_client.federate_server(
      @new_resource.server_url,
      @new_resource.server_admin_url,
      @new_resource.server_username,
      @new_resource.server_password)

    new_resource.updated_by_last_action(true)
  end
end

action :unfederate_server do
  portal_admin_client = ArcGIS::PortalAdminClient.new(@new_resource.portal_url,
                                                      @new_resource.username,
                                                      @new_resource.password)

  # Wait until Portal admin URL is available.
  portal_admin_client.wait_until_available

  servers = portal_admin_client.servers

  server = servers.detect { |s| s['url'] == @new_resource.server_url }

  if server.nil?
    Chef::Log.info("Server #{@new_resource.server_url} is not federated with the portal")
  else
    portal_admin_client.unfederate_server(server['id'])

    Chef::Log.info("Server #{@new_resource.server_url} is now unfederated from the portal")

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
      Chef::Log.info("Server #{@new_resource.server_url} is not federated with the portal")
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
    if Utils.service_started?('Portal for ArcGIS')
      # Log server.xml file size before and after the portal service stop
      server_xml = ::File.join(node['arcgis']['portal']['install_dir'], 
                               'framework\\runtime\\tomcat\\conf\\server.xml')
      server_xml_size = ::File.size(server_xml)
      # Chef::Log.info("Portal server.xml file size before service stop is #{server_xml_size} bytes.")

      Utils.stop_service('Portal for ArcGIS')

      server_xml_size = ::File.size(server_xml)
      # Chef::Log.info("Portal server.xml file size after service stop is #{server_xml_size} bytes.")
      Chef::Log.warn("Portal server.xml file is empty.") if server_xml_size == 0

      # Sleep to prevent frequent restarts of the service
      sleep(60)

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
      if node['arcgis']['cloud']['provider'] == 'ec2'
        env 'arcgis_cloud_platform' do
          value 'aws'
        end
      end
    end

    if !Utils.service_started?('Portal for ArcGIS')
      # Log server.xml file size before and after the portal service start
      server_xml = ::File.join(node['arcgis']['portal']['install_dir'], 
                              'framework\\runtime\\tomcat\\conf\\server.xml')
      server_xml_size = ::File.size(server_xml)
      # Chef::Log.info("Portal server.xml file size before service start is #{server_xml_size} bytes.")

      Utils.sc_enable('Portal for ArcGIS')
      Utils.start_service('Portal for ArcGIS')

      server_xml_size = ::File.size(server_xml)
      # Chef::Log.info("Portal server.xml file size after service start is #{server_xml_size} bytes.")
      Chef::Log.warn("Portal server.xml file is empty.") if server_xml_size == 0

      # Sleep to prevent frequent restarts of the service
      sleep(60)
      
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
        if node['arcgis']['cloud']['provider'] == 'ec2'
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
