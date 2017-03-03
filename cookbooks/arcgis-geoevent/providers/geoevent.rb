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

action :system do
  if node['platform'] == 'windows'  
    powershell_script 'Open Ports required by GeoEvent Extension' do
      code <<-EOH
        netsh advfirewall firewall add rule name="Allow_ArcGISGeoEvent_Ports2" dir=in action=allow protocol=TCP localport="2181,2182,2190,27271,27272,27273,6143,6180,5565,5570,5575" description="Allows connections through all ports used by ArcGIS GeoEvent"
      EOH
      only_if { node['platform'] == 'windows' && ENV['arcgis_cloud_platform'] == 'aws'}
      ignore_failure true
    end
  end
end

action :install do
  if node['platform'] == 'windows'
    run_as_password = @new_resource.run_as_password
    install_dir = @new_resource.install_dir

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
    if @new_resource.run_as_user.include? "\\"
      service_logon_user = @new_resource.run_as_user
    else
      service_logon_user = ".\\#{@new_resource.run_as_user}"
    end
    service_name = 'ArcGISGeoEvent'
    #Utils.retry_ShellOut("net stop \"#{service_name}\" /yes", 10, 60, {:timeout => 600})
    Utils.retry_ShellOut("sc.exe config \"#{service_name}\" obj= \"#{service_logon_user}\" password= \"#{@new_resource.run_as_password}\"",
                         1, 60, {:timeout => 600})
    #Utils.retry_ShellOut("net start \"#{service_name}\" /yes", 5, 60, {:timeout => 600})
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
end

action :start  do
  if node['platform'] == 'windows'
    service "ArcGISGeoEvent" do
      supports :status => true, :restart => true, :reload => true
      action [:enable, :start]
    end
  else
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
    geehome = ::File.join(@new_resource.install_dir,
                          node['arcgis']['server']['install_subdir'],
                          'GeoEvent')

    arcgisgeoevent = ::File.join(geehome, 'bin/ArcGISGeoEvent-service')

    if node['init_package'] == 'init' # SysV
      arcgisgeoevent_path = '/etc/init.d/arcgisgeoevent'
      service_file = 'ArcGISGeoEvent-service.erb'
      template_variables = ({ :geehome => geehome, :agsuser => agsuser })
    else # node['init_package'] == 'systemd'
      arcgisgeoevent_path = '/etc/systemd/system/arcgisgeoevent.service'
      service_file = 'geoevent.service.erb'
      template_variables = ({ :geehome => geehome, :agsuser => agsuser })
    end

    template arcgisgeoevent_path do
      source service_file
      cookbook 'arcgis-geoevent'
      variables template_variables
      owner agsuser
      group 'root'
      mode '0755'
      notifies :run, 'execute[Load systemd unit file]', :immediately
      not_if { ::File.exists?(arcgisgeoevent_path) }
    end

    execute 'Load systemd unit file' do
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
