#
# Cookbook Name:: arcgis-enterprise
# Provider:: datastore
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

if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  require 'win32/service'
end

use_inline_resources

action :system do
  case node['platform']
  when 'windows'
    # Configure Windows firewall
    windows_firewall_rule 'ArcGIS Data Store' do
      description 'Allows connections through all ports used by ArcGIS Data Store'
      local_port node['arcgis']['data_store']['ports']
      protocol 'TCP'
      firewall_action :allow
      only_if { node['arcgis']['configure_windows_firewall'] }
    end
  end

  if node['platform'] != 'windows' && node['arcgis']['run_as_superuser']
    ruby_block 'Set sysctl vm.max_map_count' do
      block do
        Utils.update_file_key_value(node['arcgis']['data_store']['sysctl_conf'],
                                    'vm.max_map_count',
                                    node['arcgis']['data_store']['vm_max_map_count'])
      end
      notifies :run, 'execute[Reload sysctl settings]', :immediately
      not_if { Utils.file_key_value_updated?(node['arcgis']['data_store']['sysctl_conf'],
                                             'vm.max_map_count',
                                             node['arcgis']['data_store']['vm_max_map_count']) }
    end

    ruby_block 'Set sysctl vm.swappiness' do
      block do
        Utils.update_file_key_value(node['arcgis']['data_store']['sysctl_conf'],
                                    'vm.swappiness',
                                    node['arcgis']['data_store']['vm_swappiness'])
      end
      notifies :run, 'execute[Reload sysctl settings]', :immediately
      not_if { Utils.file_key_value_updated?(node['arcgis']['data_store']['sysctl_conf'],
                                             'vm.swappiness',
                                             node['arcgis']['data_store']['vm_swappiness']) }
    end

    execute 'Reload sysctl settings' do
      command 'sysctl -p'
      action :nothing
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
           "USER_NAME=\"#{@new_resource.run_as_user}\" "\
           "#{password} "\
           "#{@new_resource.setup_options}"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600 })
    cmd.run_command
    Utils.sensitive_command_error(cmd, [ @new_resource.run_as_password ])

    if @new_resource.data_dir != node.default['arcgis']['data_store']['data_dir']
      properties_filename = ::File.join(@new_resource.install_dir,
                                        'framework',
                                        'arcgis-data-store-config.properties')

      if ::File.exist?(properties_filename)
        file = Chef::Util::FileEdit.new(properties_filename)
        file.search_file_replace(/dir.data.*/, "dir.data=#{@new_resource.data_dir}")
        file.write_file
      else
        ::File.open(properties_filename, 'w') { |f| f.write("dir.data=#{@new_resource.data_dir}") }
      end
    end
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['data_store']['install_subdir'])
    cmd = @new_resource.setup
    args = "-m silent -l yes -d \"#{@new_resource.install_dir}\" #{@new_resource.setup_options}"
    run_as_user = @new_resource.run_as_user

    subdir = @new_resource.install_dir
    node['arcgis']['data_store']['install_subdir'].split("/").each do |path|
      subdir = ::File.join(subdir, path)
      FileUtils.mkdir_p(subdir) unless ::File.directory?(subdir)
      FileUtils.chmod 0700, subdir
      FileUtils.chown_R run_as_user, nil, subdir
    end

    if node['arcgis']['run_as_superuser']
      cmd = Mixlib::ShellOut.new("su #{run_as_user} -c \"#{cmd} #{args}\"", { :timeout => 3600 })
    else
      cmd = Mixlib::ShellOut.new("#{cmd} #{args}", {:user => run_as_user, :timeout => 3600})
    end
    cmd.run_command
    cmd.error!

    if @new_resource.data_dir != node.default['arcgis']['data_store']['data_dir']
      properties_filename = ::File.join(install_subdir,
                                        'framework',
                                        'arcgis-data-store-config.properties')

      if ::File.exist?(properties_filename)
        file = Chef::Util::FileEdit.new(properties_filename)
        file.search_file_replace(/dir.data.*/, "dir.data=#{@new_resource.data_dir}")
        file.write_file
      else
        ::File.open(properties_filename, 'w') { |f| f.write("dir.data=#{@new_resource.data_dir}") }
      end
    end
  end

  sleep(120.0) # Wait for Data Store installation to finish

  if node['platform'] != 'windows'
    # Stop Data Store to start it later using SystemD service
    cmd = node['arcgis']['data_store']['stop_tool']

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

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", {:timeout => 3600})
    cmd.run_command
    cmd.error!
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['data_store']['install_subdir'])
    cmd = ::File.join(install_subdir, 'uninstall_ArcGISDataStore')
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
    if Utils.sc_logon_account('ArcGIS Data Store') != @new_resource.run_as_user
      datastore_tools = ArcGIS::DataStoreTools.new(node['arcgis']['version'],
                                                   node['platform'],
                                                   @new_resource.install_dir,
                                                   node['arcgis']['data_store']['install_subdir'],
                                                   @new_resource.run_as_user)

      datastore_tools.configure_service_account(@new_resource.run_as_user,
                                                @new_resource.run_as_password)
    end

    # Update logon account of the windows service directly in addition to running configureserviceaccount.bat
    Utils.sc_config('ArcGIS Data Store', @new_resource.run_as_user, @new_resource.run_as_password)
    
    new_resource.updated_by_last_action(true)
  end
end

action :configure_autostart do
  if node['platform'] == 'windows'
    service 'ArcGIS Data Store' do
      action :enable
    end
  else
    Chef::Log.info('Configure ArcGIS Data Store to be started with the operating system.')

    agsuser = node['arcgis']['run_as_user']
    datastorehome = ::File.join(@new_resource.install_dir,
                                node['arcgis']['data_store']['install_subdir'])

    # SysV
    if node['init_package'] == 'init'
      arcgisdatastore_path = '/etc/init.d/arcgisdatastore'
      service_file = 'arcgisdatastore.erb'
      template_variables = ({ :datastorehome => datastorehome })
    # Systemd
    else node['init_package'] == 'systemd'
      arcgisdatastore_path = '/etc/systemd/system/arcgisdatastore.service'
      service_file = 'arcgisdatastore.service.erb'
      template_variables = ({ :datastorehome => datastorehome, :agsuser => agsuser })
      if node['arcgis']['configure_cloud_settings']
        if node['arcgis']['cloud']['provider'] == 'ec2'
          cloudenvironment = { :cloudenvironment => 'Environment="arcgis_cloud_platform=aws"' }
          template_variables = template_variables.merge(cloudenvironment)
        end
      end
    end

    template arcgisdatastore_path do
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
#      notifies :restart, 'service[arcgisdatastore]', :immediately
    end

    service 'arcgisdatastore' do
      supports :status => true, :restart => true, :reload => true
      action :enable
    end

    new_resource.updated_by_last_action(true)
  end
end

action :stop do
  if node['platform'] == 'windows'
    if Utils.service_started?('ArcGIS Data Store')
      Utils.stop_service('ArcGIS Data Store')
      new_resource.updated_by_last_action(true)
    end
  else
    if node['arcgis']['data_store']['configure_autostart']
      service 'arcgisdatastore' do
        supports :status => true, :restart => true, :reload => true
        action :stop
      end
    else
      cmd = node['arcgis']['data_store']['stop_tool']

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

    if !Utils.service_started?('ArcGIS Data Store')
      Utils.sc_enable('ArcGIS Data Store')
      Utils.start_service('ArcGIS Data Store')
      sleep(60)
      new_resource.updated_by_last_action(true)
    end
  else
    if node['arcgis']['data_store']['configure_autostart']
      service 'arcgisdatastore' do
        supports :status => true, :restart => true, :reload => true
        notifies :run, "ruby_block[Wait for Data Store to start]", :immediately
        action [:enable, :start]
      end

      ruby_block "Wait for Data Store to start" do
        block do
          sleep(60)
        end
        action :nothing
      end
    else
      cmd = node['arcgis']['data_store']['start_tool']

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

      ruby_block "Wait for Data Store to start" do
        block do
          sleep(60)
        end
        action :run
      end
    end

    new_resource.updated_by_last_action(true)
  end
end

action :configure do
  server_admin_url = "#{@new_resource.server_url}/admin"

  Utils.wait_until_url_available(server_admin_url)

  datastore_tools = ArcGIS::DataStoreTools.new(node['arcgis']['version'],
                                               node['platform'],
                                               @new_resource.install_dir,
                                               node['arcgis']['data_store']['install_subdir'],
                                               @new_resource.run_as_user)

  datastore_tools.configure_datastore(@new_resource.types,
                                      server_admin_url,
                                      @new_resource.username,
                                      @new_resource.password,
                                      @new_resource.data_dir,
                                      @new_resource.mode)

  new_resource.updated_by_last_action(true)
end

action :configure_backup_location do
  datastore_tools = ArcGIS::DataStoreTools.new(node['arcgis']['version'],
                                               node['platform'],
                                               @new_resource.install_dir,
                                               node['arcgis']['data_store']['install_subdir'],
                                               @new_resource.run_as_user)

  operation = 'change'

  # At 10.8 tilecache backup location is no longer registered by default
  # therefore --operation register needs to be used.
  if %w[tilecache spatiotemporal graph].include?(@new_resource.store) && Gem::Version.new(node['arcgis']['version'].gsub(/\s+/, '-')) >= Gem::Version.new('10.8')
    operation = 'register'
  end

  # Because relational data stores always have default backups of 'fs' type,
  # configuring backup locations of 's3' type for relational data stores
  # need to use '--operation register' rather than '--operation change'.
  if @new_resource.store == 'relational' && @new_resource.backup_type == 's3'
    operation = 'register'
  end

  datastore_tools.configure_backup_location(@new_resource.store, @new_resource.backup_location, operation)

  new_resource.updated_by_last_action(true)
end

action :prepare_upgrade do
  server_admin_url = "#{@new_resource.server_url}/admin"

  Utils.wait_until_url_available(server_admin_url)

  datastore_tools = ArcGIS::DataStoreTools.new(node['arcgis']['version'],
                                               node['platform'],
                                               @new_resource.install_dir,
                                               node['arcgis']['data_store']['install_subdir'],
                                               @new_resource.run_as_user)

  @new_resource.types.split(',').each do |store|
    datastore_tools.prepare_upgrade(store,
                                    server_admin_url,
                                    @new_resource.username,
                                    @new_resource.password,
                                    @new_resource.data_dir)
  end
end

action :configure_hostidentifiers_properties do
  template ::File.join(node['arcgis']['data_store']['install_dir'],
                       node['arcgis']['data_store']['install_subdir'],
                       'framework', 'etc', 'hostidentifier.properties') do
    source 'hostidentifier.properties.erb'
    variables ( {:hostidentifier => node['arcgis']['data_store']['hostidentifier'],
                 :preferredidentifier => node['arcgis']['data_store']['preferredidentifier']} )
  end
end

action :remove_machine do
  hostidentifier = @new_resource.hostidentifier
  force = @new_resource.force_remove_machine ? 'true' : 'false'

  if hostidentifier.nil? || hostidentifier.empty?
    hostidentifier = @new_resource.preferredidentifier == 'hostname' ? 
                     node['hostname'] : node['ipaddress']
  end

  datastore_tools = ArcGIS::DataStoreTools.new(node['arcgis']['version'],
                                               node['platform'],
                                               @new_resource.install_dir,
                                               node['arcgis']['data_store']['install_subdir'],
                                               @new_resource.run_as_user)

  @new_resource.types.split(',').each do |store|
    datastore_tools.remove_machine(store, hostidentifier, force)
  end

  new_resource.updated_by_last_action(true)
end
