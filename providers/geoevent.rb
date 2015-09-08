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
        
    execute "Install ArcGIS GeoEvent Extension for Server" do
      command "\"#{cmd}\" #{args}"
      only_if {!::File.exists?(::File.join(install_dir,"GeoEvent\\bin\\startGeoEvent.bat"))}
    end

    service "ArcGISGeoEvent" do
      action [:stop] 
    end
    
    execute "Change 'ArcGISGeoEvent' service logon account" do
      command "sc.exe config \"ArcGISGeoEvent\" obj= \"#{service_logon_user}\" password= \"#{run_as_password}\""
      #sensitive true
    end
    
    service "ArcGIS Server" do
      action [:enable,:restart] 
    end
  else
    cmd = @new_resource.setup
    arcgisgeoevent = ::File.join(@new_resource.install_dir, node['server']['install_subdir'], "GeoEvent/bin/ArcGISGeoEvent-service")
      
    execute "Install ArcGIS GeoEvent Extension for Server" do
      command "sudo -H -u #{node['arcgis']['run_as_user']} bash -c \"#{cmd}\""
      only_if {!::File.exists?(arcgisgeoevent)}
    end

    configure_autostart(arcgisgeoevent)
  end

  new_resource.updated_by_last_action(true)
end

action :authorize do
  if !@new_resource.authorization_file.nil? && !@new_resource.authorization_file.empty?
    cmd = node['server']['authorization_tool']
  
    if node['platform'] == 'windows'
      args = "/VER #{@new_resource.authorization_file_version} /LIF \"#{@new_resource.authorization_file}\" /S"
      
      execute "Authorize ArcGIS GeoEvent Extension for Server" do
        command "\"#{cmd}\" #{args}"
      end
    else 
      args = "-f \"#{@new_resource.authorization_file}\""
    
      execute "Authorize ArcGIS GeoEvent Extension for Server" do
        command "\"#{cmd}\" #{args}"
        user node['arcgis']['run_as_user']
      end
    end
  
    new_resource.updated_by_last_action(true)
  end 
end

private

def configure_autostart(arcgisgeoevent)
  Chef::Log.info("Configure ArcGIS GeoEvent Extension for Server to be started with the operating system.")
  
  if node["platform_family"] == "rhel"
    init_d = "/etc/rc.d/init.d/"
  else  
    init_d = "/etc/init.d/"
  end
  
  execute "ln -s #{arcgisgeoevent} #{init_d}"

  service "ArcGISGeoEvent-service" do
    supports :status => true, :restart => true, :reload => true
    action [:enable, :start]
  end
end