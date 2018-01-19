#
# Cookbook Name:: arcgis-geoevent
# Provider:: geoevent
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

use_inline_resources if defined?(use_inline_resources)

action :system do
  case node['platform']
  when 'windows'
    # Configure Windows firewall
    windows_firewall_rule 'ArcGIS GeoEvent Server' do
      description 'Allows connections through all ports used by ArcGIS GeoEvent Server'
      localport node['arcgis']['geoevent']['ports']
      dir :in
      protocol 'TCP'
      firewall_action :allow
      only_if { node['arcgis']['configure_windows_firewall'] }
    end
  end
  new_resource.updated_by_last_action(true)
end

action :install do
  if node['platform'] == 'windows'
    run_as_password = @new_resource.run_as_password

    cmd = @new_resource.setup
    args = "/qb PASSWORD=\"#{run_as_password}\""

    cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 3600 })
    cmd.run_command
    cmd.error!

    sleep(450.0)  # Wait for GeoEvent Service to build dependency tree...
  else
    cmd = @new_resource.setup
    run_as_user = @new_resource.run_as_user

    cmd = Mixlib::ShellOut.new("su - #{run_as_user} -c \"#{cmd}\"",
                               { :timeout => 3600 })
    cmd.run_command
    cmd.error!
  end

  new_resource.updated_by_last_action(true)
end

action :uninstall do
  if node['platform'] == 'windows'
    cmd = 'msiexec'
    args = "/qb /x #{@new_resource.product_code}"

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
  else
    service "arcgisgeoevent" do
      supports :status => true, :restart => true, :reload => true
      action :stop
    end
  end

  new_resource.updated_by_last_action(true)
end

action :start  do
  if node['platform'] == 'windows'
    service "ArcGISGeoEvent" do
      supports :status => true, :restart => true, :reload => true
      timeout 180
      action [:enable, :start]
    end
  else
    directory ::File.join(@new_resource.install_dir,
                          node['arcgis']['server']['install_subdir'],
                          'GeoEvent/data') do
      recursive true
      owner node['arcgis']['run_as_user']
      action [:delete, :create]
    end

    service "arcgisgeoevent" do
      supports :status => true, :restart => true, :reload => true
      action [:enable, :start]
    end
  end
end

action :configure_autostart do
  if node['platform'] == 'windows'
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
      owner agsuser
      group 'root'
      mode '0755'
      notifies :run, 'execute[Load gateway systemd unit file]', :immediately
      not_if { ::File.exists?(gateway_path) }
      only_if { node['arcgis']['geoevent']['configure_gateway_service'] }
    end

    execute 'Load gateway systemd unit file' do
      command 'systemctl daemon-reload'
      action :nothing
      only_if { ( node['init_package'] == 'systemd' ) &&
                  node['arcgis']['geoevent']['configure_gateway_service'] }
      notifies :restart, 'service[geoeventGateway]', :immediately
    end

    service 'geoeventGateway' do
      supports :status => true, :restart => true, :reload => true
      action :enable
      only_if { node['arcgis']['geoevent']['configure_gateway_service'] }
    end

    template geoevent_path do
      source geoevent_service_file
      cookbook 'arcgis-geoevent'
      variables geoevent_template_variables
      owner agsuser
      group 'root'
      mode '0755'
      notifies :run, 'execute[Load geoevent systemd unit file]', :immediately
      not_if { ::File.exists?(geoevent_path) }
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
    cmd = node['arcgis']['server']['authorization_tool']

    if node['platform'] == 'windows'
      args = "/VER #{@new_resource.authorization_file_version} /LIF \"#{@new_resource.authorization_file}\" /S"

      cmd = Mixlib::ShellOut.new("\"#{cmd}\" #{args}", { :timeout => 600 })
      cmd.run_command
      cmd.error!
    else
      args = "-f \"#{@new_resource.authorization_file}\""

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
