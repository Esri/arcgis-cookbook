#
# Cookbook Name:: arcgis
# Provider:: server
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
    cmd = @new_resource.setup
    args = "/qb INSTALLDIR=\"#{@new_resource.install_dir}\" INSTALLDIR1=\"#{@new_resource.python_dir}\" USER_NAME=\"#{@new_resource.run_as_user}\" PASSWORD=\"#{@new_resource.run_as_password}\""
    install_dir = @new_resource.install_dir
    run_as_user = @new_resource.run_as_user
    run_as_password = @new_resource.run_as_password
    
    execute "Install ArcGIS for Server" do
      command "\"#{cmd}\" #{args}"
      only_if {!::File.exists?(::File.join(install_dir,"\\framework\\etc\\scripts\\startserver.bat"))}
    end

    service "ArcGIS Server" do
      action [:stop] 
    end
    
    if run_as_user.include? "\\"
      service_logon_user = run_as_user
    else
      service_logon_user = ".\\#{run_as_user}"
    end

    execute "Change 'ArcGIS Server' service logon account" do
      command "sc.exe config \"ArcGIS Server\" obj= \"#{service_logon_user}\" password= \"#{run_as_password}\""
      #sensitive true
    end
    
    service "ArcGIS Server" do
      action [:enable,:restart] 
    end
  else
    cmd = @new_resource.setup
    args = "-m silent -l yes -d \"#{@new_resource.install_dir}\""
    install_subdir = ::File.join(@new_resource.install_dir, node['server']['install_subdir'])
    run_as_user = @new_resource.run_as_user
      
    subdir = @new_resource.install_dir
    node['server']['install_subdir'].split("/").each do |path|
      subdir = ::File.join(subdir, path)
      directory subdir do
        owner run_as_user
        group 'root'
        mode '0755'
        action :create
      end
    end
        
    execute "Install ArcGIS for Server" do
      command "sudo -H -u #{node['arcgis']['run_as_user']} bash -c \"#{cmd} #{args}\""
      only_if {!::File.exists?(::File.join(install_subdir, "startserver.sh"))}
    end

    configure_autostart(install_subdir)
  end

  new_resource.updated_by_last_action(true)
end

action :authorize do
  cmd = node['server']['authorization_tool']

  if node['platform'] == 'windows'
    args = "/VER #{@new_resource.authorization_file_version} /LIF \"#{@new_resource.authorization_file}\" /S"
    
    execute "Authorize ArcGIS for Server" do
      command "\"#{cmd}\" #{args}"
    end
  else 
    args = "-f \"#{@new_resource.authorization_file}\""
  
    execute "Authorize ArcGIS for Server" do
      command "\"#{cmd}\" #{args}"
      user node['arcgis']['run_as_user']
    end
  end

  new_resource.updated_by_last_action(true)
end

action :create_site do
  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url, @new_resource.username, @new_resource.password)
  
  admin_client.wait_until_available()
  
  if admin_client.site_exist?
    Chef::Log.warn("ArcGIS Server site already exists.")
  else
    admin_client.create_site(@new_resource.server_directories_root)

    new_resource.updated_by_last_action(true)
  end
end

action :join_site do
  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url, @new_resource.username, @new_resource.password)
  
  admin_client.wait_until_available()

  if admin_client.site_exist?
    Chef::Log.warn("Machine is already connected to an ArcGIS Server site.")
  else
    primary_admin_client = ArcGIS::ServerAdminClient.new(@new_resource.primary_server_url, @new_resource.username, @new_resource.password)

    primary_admin_client.wait_until_site_exist()
          
    admin_client.join_site(@new_resource.primary_server_url)

    new_resource.updated_by_last_action(true)
  end
end

action :join_cluster do
  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url, @new_resource.username, @new_resource.password)
  
  admin_client.wait_until_available()

  machine_name = admin_client.get_local_machine_name()

  admin_client.add_machine_to_cluster(machine_name, @new_resource.cluster)

  new_resource.updated_by_last_action(true)
end

action :enable_ssl do
  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url, @new_resource.username, @new_resource.password)
  
  admin_client.enable_ssl()
 
  new_resource.updated_by_last_action(true)
end

action :register_database do
  admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url, @new_resource.username, @new_resource.password)

  admin_client.register_database(@new_resource.data_item_path, @new_resource.connection_string, @new_resource.is_managed)

  new_resource.updated_by_last_action(true)
end

action :federate do
  server_id = @new_resource.server_id
  secret_key = @new_resource.secret_key
    
  if server_id.nil?
    server_id = node['server']['server_id']
  end
  
  if secret_key.nil?
    secret_key = node['server']['secret_key']
  end 

  if !server_id.nil? && !secret_key.nil? 
    portal_admin_client = ArcGIS::PortalAdminClient.new(@new_resource.portal_url, @new_resource.portal_username, @new_resource.portal_password)
  
    portal_admin_client.wait_until_available()
  
    portal_token = portal_admin_client.generate_token(@new_resource.portal_url + '/sharing/generateToken')
    
    server_admin_client = ArcGIS::ServerAdminClient.new(@new_resource.server_url, @new_resource.username, @new_resource.password)
    
    server_admin_client.wait_until_available()
    
    server_admin_client.federate(@new_resource.portal_url, portal_token, server_id, secret_key)
    
    new_resource.updated_by_last_action(true)
  end
end

private

def configure_autostart(agshome)
  Chef::Log.info("Configure ArcGIS for Server to be started with the operating system.")
  
  arcgisserver_path = "/etc/init.d/arcgisserver"
  
  if node["platform_family"] == "rhel"
    arcgisserver_path = "/etc/rc.d/init.d/arcgisserver" 
  end
  
  template arcgisserver_path do 
    source "arcgisserver.erb"
    variables ({:agshome => agshome})
    owner "root"
    group "root"
    mode 0755
    only_if {!::File.exists?(arcgisserver_path)}
  end

  service "arcgisserver" do
    supports :status => true, :restart => true, :reload => true
    action [:enable, :start]
  end
end