#
# Cookbook Name:: arcgis-geoevent
# Provider:: geoevent
#
# Copyright 2015-2024 Esri
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

use_inline_resources if defined?(use_inline_resources)

action :system do
  case node['platform']
  when 'windows'
    # Configure Windows firewall
    windows_firewall_rule 'ArcGIS GeoEvent Server' do
      description 'Allows connections through all ports used by ArcGIS GeoEvent Server'
      local_port node['arcgis']['geoevent']['ports']
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
    args = "/qn #{password} #{@new_resource.setup_options}"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600 })
    cmd.run_command
    Utils.sensitive_command_error(cmd, [ @new_resource.run_as_password ])

    sleep(450.0)  # Wait for GeoEvent Service to build dependency tree...
  else
    cmd = @new_resource.setup
    args = @new_resource.setup_options
    run_as_user = @new_resource.run_as_user

    cmd = Mixlib::ShellOut.new("su - #{run_as_user} -c \"#{cmd} #{args}\"",
                               { :timeout => 3600 })
    cmd.run_command
    cmd.error!
  end

  new_resource.updated_by_last_action(true)
end

action :uninstall do
  if node['platform'] == 'windows'
    cmd = 'msiexec'
    args = "/qn /x #{@new_resource.product_code}"

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600 })
    cmd.run_command
    cmd.error!
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['server']['install_subdir'])
    cmd = ::File.join(install_subdir, 'uninstall_GeoEvent.sh')
    args = '-s'

    cmd = Mixlib::ShellOut.new("su - #{@new_resource.run_as_user} -c \"#{cmd} #{args}\"",
                               { :timeout => 3600 })
    cmd.run_command
    cmd.error!

    #disable_autostart()
  end

  new_resource.updated_by_last_action(true)
end

action :update_account do
  if node['platform'] == 'windows'
    Utils.sc_config('ArcGISGeoEvent', @new_resource.run_as_user, @new_resource.run_as_password)
    Utils.sc_config('ArcGISGeoEventGateway', @new_resource.run_as_user, @new_resource.run_as_password)

    new_resource.updated_by_last_action(true)
  end
end

action :stop do
  if node['platform'] == 'windows'
    service "ArcGISGeoEvent" do
      supports :status => true, :restart => true, :reload => true
      action :stop
    end

    service "ArcGISGeoEventGateway" do
      supports :status => true, :restart => true, :reload => true
      action :stop
    end
  else
    if node['arcgis']['geoevent']['configure_autostart']
      service "arcgisgeoevent" do
        supports :status => true, :restart => true, :reload => true
        action :stop
      end

      service "geoeventGateway" do
        supports :status => true, :restart => true, :reload => true
        action :stop
      end
    else
      # stop geoevent gateway service
      cmd = ::File.join(@new_resource.install_dir,
                        node['arcgis']['server']['install_subdir'],
                        '/GeoEvent/gateway/bin',
                        '/ArcGISGeoEventGateway-service')

      if node['arcgis']['run_as_superuser']
        cmd = Mixlib::ShellOut.new("su #{node['arcgis']['run_as_user']} -c \"#{cmd} stop\"", {:timeout => 60})
      else
        cmd = Mixlib::ShellOut.new("#{cmd} #{args}", {:timeout => 60})
      end
      cmd.run_command
      cmd.error!
      new_resource.updated_by_last_action(true)

      # stop geoevent service
      cmd = ::File.join(@new_resource.install_dir,
                        node['arcgis']['server']['install_subdir'],
                        '/GeoEvent/bin',
                        '/ArcGISGeoEvent-service')

      if node['arcgis']['run_as_superuser']
        cmd = Mixlib::ShellOut.new("su #{node['arcgis']['run_as_user']} -c \"#{cmd} stop\"", {:timeout => 60})
      else
        cmd = Mixlib::ShellOut.new("#{cmd} #{args}", {:timeout => 60})
      end
      cmd.run_command
      cmd.error!
    end
  end

  new_resource.updated_by_last_action(true)
end

action :start  do
  if node['platform'] == 'windows'
    service "ArcGISGeoEventGateway" do
      supports :status => true, :restart => true, :reload => true
      timeout 180
      action [:enable, :start]
    end

    # Give the service 30 - 60 seconds to complete its start-up,
    # so that the Kafka and Zookeeper resources are initialized.
    ruby_block 'Wait for GeoEvent gateway service to start' do
      block do
        sleep(30)
      end
    end

    service "ArcGISGeoEvent" do
      supports :status => true, :restart => true, :reload => true
      timeout 180
      action [:enable, :start]
    end
  else
    if node['arcgis']['geoevent']['configure_autostart']
      service "geoeventGateway" do
        supports :status => true, :restart => true, :reload => true
        action [:enable, :start]
      end

      ruby_block 'Wait for GeoEvent gateway service to start' do
        block do
          sleep(30)
        end
      end

      service "arcgisgeoevent" do
        supports :status => true, :restart => true, :reload => true
        action [:enable, :start]
      end
    else
      # start geoevent gateway service
      cmd = ::File.join(@new_resource.install_dir,
                        node['arcgis']['server']['install_subdir'],
                        '/GeoEvent/gateway/bin',
                        '/ArcGISGeoEventGateway-service')

      if node['arcgis']['run_as_superuser']
        cmd = Mixlib::ShellOut.new("su #{node['arcgis']['run_as_user']} -c \"#{cmd} start\"", {:timeout => 60})
      else
        cmd = Mixlib::ShellOut.new("#{cmd} #{args}", {:timeout => 60})
      end
      cmd.run_command
      cmd.error!
      new_resource.updated_by_last_action(true)

      # start geoevent service
      cmd = ::File.join(@new_resource.install_dir,
                        node['arcgis']['server']['install_subdir'],
                        '/GeoEvent/bin',
                        '/ArcGISGeoEvent-service')

      if node['arcgis']['run_as_superuser']
        cmd = Mixlib::ShellOut.new("su #{node['arcgis']['run_as_user']} -c \"#{cmd} start\"", {:timeout => 60})
      else
        cmd = Mixlib::ShellOut.new("#{cmd} #{args}", {:timeout => 60})
      end
      cmd.run_command
      cmd.error!
    end      
  end

  new_resource.updated_by_last_action(true)
end

action :configure_autostart do
  if node['platform'] == 'windows'
    service "ArcGISGeoEventGateway" do
      supports :status => true, :restart => true, :reload => true
      action :enable
    end

    service "ArcGISGeoEvent" do
      supports :status => true, :restart => true, :reload => true
      action :enable
    end
  else
    Chef::Log.info('Configure ArcGIS GeoEvent Server to be started with the operating system.')

    agsuser = node['arcgis']['run_as_user']
    agshome = ::File.join(@new_resource.install_dir,
                          node['arcgis']['server']['install_subdir'])

    if node['init_package'] == 'init' # SysV
      gateway_path = '/etc/init.d/geoeventGateway'
      gateway_service_file = 'ArcGISGeoEventGateway-service.erb'
      gateway_template_variables = ({ :agshome => agshome, :agsuser => agsuser })

      geoevent_path = '/etc/init.d/arcgisgeoevent'
      geoevent_service_file = 'ArcGISGeoEvent-service.erb'
      geoevent_template_variables = ({ :agshome => agshome, :agsuser => agsuser })
    else # node['init_package'] == 'systemd'
      gateway_path = '/etc/systemd/system/geoeventGateway.service'
      gateway_service_file = 'geoeventGateway.service.erb'
      gateway_template_variables = ({ :agshome => agshome, :agsuser => agsuser })

      geoevent_path = '/etc/systemd/system/arcgisgeoevent.service'
      geoevent_service_file = 'geoevent.service.erb'
      geoevent_template_variables = ({ :agshome => agshome, :agsuser => agsuser })
    end

    template gateway_path do
      source gateway_service_file
      cookbook 'arcgis-geoevent'
      variables gateway_template_variables
      owner 'root'
      group 'root'
      mode '0600'
      notifies :run, 'execute[Load gateway systemd unit file]', :immediately
    end

    execute 'Load gateway systemd unit file' do
      command 'systemctl daemon-reload'
      action :nothing
      only_if { node['init_package'] == 'systemd' }
      notifies :restart, 'service[geoeventGateway]', :immediately
    end

    service 'geoeventGateway' do
      supports :status => true, :restart => true, :reload => true
      action :enable
    end

    template geoevent_path do
      source geoevent_service_file
      cookbook 'arcgis-geoevent'
      variables geoevent_template_variables
      owner 'root'
      group 'root'
      mode '0600'
      notifies :run, 'execute[Load geoevent systemd unit file]', :immediately
    end

    execute 'Load geoevent systemd unit file' do
      command 'systemctl daemon-reload'
      action :nothing
      only_if {( node['init_package'] == 'systemd' )}
      notifies :restart, 'service[arcgisgeoevent]', :immediately
    end

    service 'arcgisgeoevent' do
      supports :status => true, :restart => true, :reload => true
      action :enable
    end

    new_resource.updated_by_last_action(true)
  end
end

action :authorize do
  if !@new_resource.authorization_file.nil? && !@new_resource.authorization_file.empty?
    unless ::File.exists?(@new_resource.authorization_file)
      raise "File '#{@new_resource.authorization_file}' not found."
    end

    cmd = node['arcgis']['server']['authorization_tool']

    if node['platform'] == 'windows'
      args = "/VER #{@new_resource.authorization_file_version} /LIF \"#{@new_resource.authorization_file}\" /S #{@new_resource.authorization_options}"

      cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 600 })
      cmd.run_command
      cmd.error!
    else
      args = "-f \"#{@new_resource.authorization_file}\" #{@new_resource.authorization_options}"

      cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}",
            { :timeout => 600, :user => node['arcgis']['run_as_user'] })
      cmd.run_command
      cmd.error!
    end

    new_resource.updated_by_last_action(true)
  end
end

def disable_autostart()
  Chef::Log.info('Disable starting the ArcGIS GeoEvent daemon when the machine is rebooted.')

  if ['rhel', 'centos'].include?(node['platform_family'])
    cmd = Mixlib::ShellOut.new('sudo chkconfig ArcGISGeoEvent-service off')
    cmd.run_command
    cmd.error!
    cmd = Mixlib::ShellOut.new('sudo chkconfig --del ArcGISGeoEvent-service')
    cmd.run_command
    cmd.error!
    cmd = Mixlib::ShellOut.new('sudo rm /etc/init.d/ArcGISGeoEvent-service')
    cmd.run_command
    cmd.error!
  else
    cmd = Mixlib::ShellOut.new('sudo update-rc.d -f ArcGISGeoEvent-service remove')
    cmd.run_command
    cmd.error!
    cmd = Mixlib::ShellOut.new('sudo rm /etc/init.d/ArcGISGeoEvent-service')
    cmd.run_command
    cmd.error!
  end
end
