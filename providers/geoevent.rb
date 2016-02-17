#
# Cookbook Name:: arcgis
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
  powershell_script 'Open Ports required by GeoEvent Extension' do
    code <<-EOH
      netsh advfirewall firewall add rule name="Allow_ArcGISGeoEvent_Ports2" dir=in action=allow protocol=TCP localport="2181,2182,2190,27271,27272,27273,6143,6180,5565,5570,5575" description="Allows connections through all ports used by ArcGIS GeoEvent"
    EOH
    only_if { node['platform'] == 'windows' && ENV['arcgis_cloud_platform'] == 'aws'}
    ignore_failure true
  end
end

action :install do
  if node['platform'] == 'windows'
    run_as_password = @new_resource.run_as_password
    install_dir = @new_resource.install_dir

    if @new_resource.run_as_user.include? "\\"
      service_logon_user = @new_resource.run_as_user
    else
      service_logon_user = ".\\#{@new_resource.run_as_user}"
    end

    cmd = @new_resource.setup
    args = "/qb PASSWORD=\"#{run_as_password}\""

    execute 'Install ArcGIS GeoEvent Extension for Server' do
      command "\"#{cmd}\" #{args}"
      only_if { !::File.exist?(::File.join(install_dir, 'GeoEvent\\bin\\startGeoEvent.bat')) }
      notifies :run, 'ruby_block[Wait for GeoEvent Service to build dependency tree]', :immediately
    end

    ruby_block 'Wait for GeoEvent Service to build dependency tree' do
      block do
        sleep(450.0)
      end
      action :nothing
    end

    service 'ArcGISGeoEvent' do
      action [:stop]
    end

    execute 'Change ArcGISGeoEvent service logon account' do
      command "sc.exe config \"ArcGISGeoEvent\" obj= \"#{service_logon_user}\" password= \"#{run_as_password}\""
      # sensitive true
    end

    service 'ArcGISGeoEvent' do
      action [:enable, :restart]
    end
  else
    cmd = @new_resource.setup
    run_as_user = @new_resource.run_as_user
    arcgisgeoevent = ::File.join(@new_resource.install_dir, 
                                 node['arcgis']['server']['install_subdir'],
                                 'GeoEvent/bin/ArcGISGeoEvent-service')

    execute 'Install ArcGIS GeoEvent Extension for Server' do
      command "su - #{run_as_user} -c \"#{cmd}\""
      only_if { !::File.exists?(arcgisgeoevent) }
    end

    configure_autostart(arcgisgeoevent)
  end

  new_resource.updated_by_last_action(true)
end

action :uninstall do
  if node['platform'] == 'windows'
    product_code = @new_resource.product_code
    cmd = 'msiexec'
    args = "/qb /x #{product_code}"

    execute 'Uninstall ArcGIS GeoEvent Extension for Server' do
      command "\"#{cmd}\" #{args}"
      only_if { Utils.product_installed?(product_code) }
    end
  else
    install_subdir = ::File.join(@new_resource.install_dir,
                                 node['arcgis']['server']['install_subdir'])
    cmd = ::File.join(install_subdir, 'uninstall_GeoEvent.sh')
    args = '-s'

    service 'ArcGISGeoEvent-service' do
      action :stop
    end

    execute 'Uninstall ArcGIS GeoEvent Extension for Server' do
      command "su - #{node['arcgis']['run_as_user']} -c \"#{cmd} #{args}\""
      only_if { ::File.exist?(cmd) }
    end

    #disable_autostart()
  end

  new_resource.updated_by_last_action(true)
end

action :authorize do
  if !@new_resource.authorization_file.nil? && !@new_resource.authorization_file.empty?
    cmd = node['arcgis']['server']['authorization_tool']

    if node['platform'] == 'windows'
      args = "/VER #{@new_resource.authorization_file_version} /LIF \"#{@new_resource.authorization_file}\" /S"

      execute 'Authorize ArcGIS GeoEvent Extension for Server' do
        command "\"#{cmd}\" #{args}"
      end
    else
      args = "-f \"#{@new_resource.authorization_file}\""

      execute 'Authorize ArcGIS GeoEvent Extension for Server' do
        command "\"#{cmd}\" #{args}"
        user node['arcgis']['run_as_user']
      end
    end

    new_resource.updated_by_last_action(true)
  end
end

private

def configure_autostart(arcgisgeoevent)
  Chef::Log.info('Configure ArcGIS GeoEvent Extension for Server to be started with the operating system.')

  if ['rhel', 'centos'].include?(node['platform_family'])
    init_d = '/etc/rc.d/init.d/'
  else
    init_d = '/etc/init.d/'
  end

  execute "ln -s #{arcgisgeoevent} #{init_d}"

  service "ArcGISGeoEvent-service" do
    supports :status => true, :restart => true, :reload => true
    action [:enable, :start]
  end
end

def disable_autostart()
  Chef::Log.info('Disable starting the ArcGIS GeoEvent daemon when the machine is rebooted.')

  if ['rhel', 'centos'].include?(node['platform_family'])
    execute 'sudo chkconfig ArcGISGeoEvent-service off'
    execute 'sudo chkconfig --del ArcGISGeoEvent-service'
    execute 'sudo rm /etc/init.d/ArcGISGeoEvent-service'
  else
    execute 'sudo update-rc.d -f ArcGISGeoEvent-service remove'
    execute 'sudo rm /etc/init.d/ArcGISGeoEvent-service'
  end
end
