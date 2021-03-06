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
    cmd.error!

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
    configureserviceaccount = ::File.join(@new_resource.install_dir, 'tools',
                                          'configureserviceaccount.bat')
    run_as_password = @new_resource.run_as_password.gsub("&", "^&")
    args = "/username \"#{@new_resource.run_as_user}\" "\
           "/password \"#{run_as_password}\""

    cmd = Mixlib::ShellOut.new("cmd.exe /C \"\"#{configureserviceaccount}\" #{args}\"",
                               { :timeout => 3600 })
    cmd.run_command
    cmd.error!

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
  begin
    server_admin_url = "#{@new_resource.server_url}/admin"

    Utils.wait_until_url_available(server_admin_url)

    if node['platform'] == 'windows'
      cmd = ::File.join(@new_resource.install_dir, 'tools\\configuredatastore')
      args = "\"#{server_admin_url}\" \"#{@new_resource.username}\" \"#{@new_resource.password}\" \"#{@new_resource.data_dir}\" --stores #{@new_resource.types}"

      if !@new_resource.mode.nil? && !@new_resource.mode.empty? &&
         Gem::Version.new(node['arcgis']['version']) >= Gem::Version.new('10.8.1') &&
         @new_resource.types.downcase.include?('tilecache')
        args += " --mode #{@new_resource.mode}"
      end

      env = { 'AGSDATASTORE' => @new_resource.install_dir }

      cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
            { :timeout => 10800, :environment => env })
      cmd.run_command
      cmd.error!
    else
      install_subdir = ::File.join(@new_resource.install_dir,
                                   node['arcgis']['data_store']['install_subdir'])
      cmd = ::File.join(install_subdir, 'tools/configuredatastore.sh')
      args = "\"#{server_admin_url}\" \"#{@new_resource.username}\" \"#{@new_resource.password}\" \"#{@new_resource.data_dir}\" --stores #{@new_resource.types}"

      if !@new_resource.mode.nil? && !@new_resource.mode.empty? &&
        Gem::Version.new(node['arcgis']['version']) >= Gem::Version.new('10.8.1') &&
        @new_resource.types.downcase.include?('tilecache')
       args += " --mode #{@new_resource.mode}"
      end

      run_as_user = @new_resource.run_as_user

      cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
            { :timeout => 10800, :user => run_as_user })
      cmd.run_command
      cmd.error!
    end

    new_resource.updated_by_last_action(true)
  rescue Exception => e
    Chef::Log.error "Failed to configure ArcGIS Data Store. " + e.message
    raise e
  end
end

action :configure_backup_location do
  operation = 'change'

  # At 10.8 tilecache backup location is no longer registered by default
  # therefore --operation register needs to be used.
  if %w[tilecache spatiotemporal].include?(@new_resource.store) && Gem::Version.new(node['arcgis']['version']) >= Gem::Version.new('10.8')
    operation = 'register'
  end

  if node['platform'] == 'windows'
    cmd = ::File.join(@new_resource.install_dir, 'tools\\configurebackuplocation')
    args = "--location \"#{@new_resource.backup_location}\" --operation #{operation} --store #{@new_resource.store} --prompt no"
    env = { 'AGSDATASTORE' => @new_resource.install_dir }

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
                               { :timeout => 600, :environment => env })
    cmd.run_command
    if cmd.error? && (cmd.stderr.include?('Operation is not supported under this configuration.') ||
                      cmd.stderr.include?('Backup location already exists.'))
      Chef::Log.debug(cmd.stderr)

      cmd = ::File.join(@new_resource.install_dir, 'tools\\configurebackuplocation')
      args = "--location \"#{@new_resource.backup_location}\" --operation change --store #{@new_resource.store} --prompt no"
      cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
                                 { :timeout => 600, :environment => env })
      cmd.run_command
    end

    cmd.error!
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['data_store']['install_subdir'])
    cmd = ::File.join(install_subdir, 'tools/configurebackuplocation.sh')
    args = "--location \"#{@new_resource.backup_location}\" --operation #{operation} --store #{@new_resource.store} --prompt no"
    run_as_user = @new_resource.run_as_user

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
                               { :timeout => 600, :user => run_as_user })
    cmd.run_command

    if cmd.error? && (cmd.stderr.include?('Operation is not supported under this configuration.') ||
                      cmd.stderr.include?('Backup location already exists.'))
      Chef::Log.debug(cmd.stderr)

      cmd = ::File.join(install_subdir, 'tools/configurebackuplocation.sh')
      args = "--location \"#{@new_resource.backup_location}\" --operation change --store #{@new_resource.store} --prompt no"
      cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
                                 { :timeout => 600, :user => run_as_user })
      cmd.run_command
    end

    cmd.error!
  end

  new_resource.updated_by_last_action(true)
end

action :prepare_upgrade do
  @new_resource.types.split(',').each do |type| 
    if node['platform'] == 'windows'
      cmd = ::File.join(@new_resource.install_dir, 'tools\\prepareupgrade.bat')
      args = "--store \"#{type}\" --server-url \"#{@new_resource.server_url}\" --server-admin \"#{@new_resource.username}\" --server-password \"#{@new_resource.password}\" --data-dir \"#{@new_resource.data_dir}\" --prompt no"
      env = { 'AGSDATASTORE' => @new_resource.install_dir }
    else
      install_subdir = ::File.join(@new_resource.install_dir,
                                  node['arcgis']['data_store']['install_subdir'])
      cmd = ::File.join(install_subdir, 'tools/prepareupgrade.sh')
      args = "--store \"#{type}\" --server-url \"#{@new_resource.server_url}\" --server-admin \"#{@new_resource.username}\" --server-password \"#{@new_resource.password}\" --data-dir \"#{@new_resource.data_dir}\" --prompt no"
    end

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
                              { :timeout => 600,
                                :environment => env})
    cmd.run_command
    cmd.error!
  end 

  new_resource.updated_by_last_action(true)
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
    if @new_resource.preferredidentifier == 'hostname'
      hostidentifier = node['hostname']
    else
      hostidentifier = node['ipaddress']
    end
  end

  @new_resource.types.split(',').each do |type|
    if node['platform'] == 'windows'
      cmd = ::File.join(@new_resource.install_dir, 'tools\\removemachine')
      args = "#{hostidentifier} --store #{type} --force #{force} --prompt no"
      env = { 'AGSDATASTORE' => @new_resource.install_dir }

      cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
                                { :timeout => 600, :environment => env })
      cmd.run_command
      cmd.error!
    else
      install_subdir = ::File.join(@new_resource.install_dir,
                                  node['arcgis']['data_store']['install_subdir'])
      cmd = ::File.join(install_subdir, 'tools/removemachine.sh')
      args = "#{hostidentifier} --store #{type} --force #{force} --prompt no"
      run_as_user = @new_resource.run_as_user

      cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
                                { :timeout => 600, :user => run_as_user })
      cmd.run_command
      cmd.error!
    end
  end 

  new_resource.updated_by_last_action(true)
end
