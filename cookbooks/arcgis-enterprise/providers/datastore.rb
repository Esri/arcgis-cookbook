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
      localport '2443,9220,9320,9876,29080,29081'
      dir :in
      protocol 'TCP'
      firewall_action :allow
      only_if { node['arcgis']['configure_windows_firewall'] }
    end
  when 'redhat', 'centos'
    ['fontconfig', 'freetype', 'gettext', 'libxkbfile', 'libXtst', 'libXrender', 'dos2unix'].each do |pckg|
      yum_package @new_resource.recipe_name + ':datastore:' + pckg do
        options '--enablerepo=*-optional'
        package_name pckg
        action :install
      end
    end
  when 'suse'
    ['libGLU1', 'libXdmcp6', 'xorg-x11-server', 'libXfont1'].each do |pckg|
      package @new_resource.recipe_name + ':datastore:' + pckg do
        package_name pckg
        action :install
      end
    end
  else
    # NOTE: ArcGIS products are not officially supported on debian platform family
    ['xserver-common', 'xvfb', 'libfreetype6', 'fontconfig', 'libxfont1',
     'libpixman-1-0', 'libgl1-mesa-dri', 'libgl1-mesa-glx', 'libglu1-mesa',
     'libpng12-0', 'x11-xkb-utils', 'libapr1', 'libxrender1', 'libxi6',
     'libxtst6', 'libaio1', 'nfs-kernel-server', 'autofs',
     'libxkbfile1'].each do |pckg|
      package @new_resource.recipe_name + ':datastore:' + pckg do
        package_name pckg
        action :install
      end
    end

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
  if node['platform'] == 'windows'
    cmd = @new_resource.setup
    args = "/qb INSTALLDIR=\"#{@new_resource.install_dir}\" "\
           "USER_NAME=\"#{@new_resource.run_as_user}\" "\
           "PASSWORD=\"#{@new_resource.run_as_password}\""

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

    if node['arcgis']['data_store']['preferredidentifier'] != 'hostname'
      hostidentifier_properties_path = ::File.join(@new_resource.install_dir,
                                                   'framework',
                                                   'etc',
                                                   'hostidentifier.properties')

      if ::File.exists?(hostidentifier_properties_path)
        file = Chef::Util::FileEdit.new(hostidentifier_properties_path)
        file.search_file_replace(/^#preferredidentifier.*/, "preferredidentifier=#{node['arcgis']['data_store']['preferredidentifier']}")
        file.search_file_replace(/^preferredidentifier.*/, "preferredidentifier=#{node['arcgis']['data_store']['preferredidentifier']}")
        file.write_file
      else
        begin
          ::File.open(hostidentifier_properties_path, 'w') { |f| f.write("preferredidentifier=#{node['arcgis']['data_store']['preferredidentifier']}") }
        rescue Exception => e
          Chef::Log.warn "Failed to set preferredidentifier property. " + e.message
        end
      end
    end
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['data_store']['install_subdir'])
    cmd = @new_resource.setup
    args = "-m silent -l yes -d \"#{@new_resource.install_dir}\""
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

    if node['arcgis']['data_store']['preferredidentifier'] != 'hostname'
      hostidentifier_properties_path = ::File.join(install_subdir,
                                                   'framework',
                                                   'etc',
                                                   'hostidentifier.properties')

      if ::File.exists?(hostidentifier_properties_path)
        file = Chef::Util::FileEdit.new(hostidentifier_properties_path)
        file.search_file_replace(/^#preferredidentifier.*/, "preferredidentifier=#{node['arcgis']['data_store']['preferredidentifier']}")
        file.search_file_replace(/^preferredidentifier.*/, "preferredidentifier=#{node['arcgis']['data_store']['preferredidentifier']}")
        file.write_file
      else
        begin
          ::File.open(hostidentifier_properties_path, 'w') { |f| f.write("preferredidentifier=#{node['arcgis']['data_store']['preferredidentifier']}") }
        rescue Exception => e
          Chef::Log.warn "Failed to set preferredidentifier property. " + e.message
        end
      end
    end
  end

  sleep(120.0) # Wait for Data Store installation to finish

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

    args = "/username #{@new_resource.run_as_user} "\
           "/password #{@new_resource.run_as_password}"

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
    end

    template arcgisdatastore_path do
      source service_file
      cookbook 'arcgis-enterprise'
      variables template_variables
      owner 'root'
      group 'root'
      mode '0755'
      notifies :run, 'execute[Load systemd unit file]', :immediately
      not_if { ::File.exists?(arcgisdatastore_path) }
    end

    execute 'Load systemd unit file' do
      command 'systemctl daemon-reload'
      action :nothing
      only_if {( node['init_package'] == 'systemd' )}
      notifies :restart, 'service[arcgisdatastore]', :immediately
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
    if ::Win32::Service.status('ArcGIS Data Store').current_state == 'running'
      service 'ArcGIS Data Store' do
        action :stop
      end
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
    if ::Win32::Service.status('ArcGIS Data Store').current_state != 'running'
      service 'ArcGIS Data Store' do
        notifies :run, "ruby_block[Wait for Data Store to start]", :immediately
        action [:enable, :start]
      end

      ruby_block "Wait for Data Store to start" do
        block do
          sleep(60)
        end
        action :nothing
      end

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
      env = { 'AGSDATASTORE' => @new_resource.install_dir }

      cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
            { :timeout => 1200, :environment => env })
      cmd.run_command
      cmd.error!
    else
      install_subdir = ::File.join(@new_resource.install_dir,
                                   node['arcgis']['data_store']['install_subdir'])
      cmd = ::File.join(install_subdir, 'tools/configuredatastore.sh')
      args = "\"#{server_admin_url}\" \"#{@new_resource.username}\" \"#{@new_resource.password}\" \"#{@new_resource.data_dir}\" --stores #{@new_resource.types}"
      run_as_user = @new_resource.run_as_user

      cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
            { :timeout => 1200, :user => run_as_user })
      cmd.run_command
      cmd.error!
    end

    new_resource.updated_by_last_action(true)
  rescue Exception => e
    Chef::Log.error "Failed to configure ArcGIS Data Store. " + e.message
    raise e
  end
end

action :change_backup_location do
  if node['platform'] == 'windows'
    cmd = ::File.join(@new_resource.install_dir, 'tools\\changebackuplocation')
    is_shared_folder = @new_resource.backup_dir.start_with?('\\\\')? 'true' : 'false'
    args = "\"#{@new_resource.backup_dir}\" --is-shared-folder #{is_shared_folder} --prompt no"
    env = { 'AGSDATASTORE' => @new_resource.install_dir }

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
                               { :timeout => 600, :environment => env })
    cmd.run_command
    cmd.error!
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['data_store']['install_subdir'])
    cmd = ::File.join(install_subdir, 'tools/changebackuplocation.sh')
    args = "\"#{@new_resource.backup_dir}\" --is-shared-folder true --prompt no"
    run_as_user = @new_resource.run_as_user

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
                               { :timeout => 600, :user => run_as_user })
    cmd.run_command
    cmd.error!
  end

  new_resource.updated_by_last_action(true)
end
