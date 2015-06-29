#
# Cookbook Name:: arcgis
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

if RUBY_PLATFORM =~ /mswin|mingw32|windows/
  require 'win32/service'
end

action :install do
  if node['platform'] == 'windows' 
    cmd = @new_resource.setup
    install_dir = @new_resource.install_dir
    args = "/qb INSTALLDIR=\"#{install_dir}\""
    run_as_user = @new_resource.run_as_user
    run_as_password = @new_resource.run_as_password

    execute "Install Portal for ArcGIS" do
      command "\"#{cmd}\" #{args}"
      only_if {!::Win32::Service.exists?("Portal for ArcGIS")}
    end

    service "Portal for ArcGIS" do
      action [:stop] 
    end
    
    execute "Grant 'Portal for ArcGIS' service logon account access to install directory" do
      command "icacls.exe \"#{install_dir}\" /grant #{run_as_user}:(OI)(CI)F"
      only_if {::File.exists?(install_dir)}
    end

    ruby_block "Grant 'Portal for ArcGIS' service logon account access to data directory" do
      block do
        properties_filename = ::File.join(install_dir, "etc", "portal-config.properties")
        if ::File.exists?(properties_filename)
          config_properties = Utils.load_properties(properties_filename)
          dir_data = config_properties['dir.data']
          if !dir_data.nil? && ::File.exists?(dir_data)
            `icacls.exe \"#{dir_data}\" /grant #{run_as_user}:(OI)(CI)F`
          end
        end
      end
      action :run
    end
    
    if run_as_user.include? "\\"
      service_logon_user = run_as_user
    else
      service_logon_user = ".\\#{run_as_user}"
    end
            
    execute "Change 'Portal for ArcGIS' service logon account" do
      command "sc.exe config \"Portal for ArcGIS\" obj= \"#{service_logon_user}\" password= \"#{run_as_password}\""
      #sensitive true
    end

    service "Portal for ArcGIS" do
      action [:enable,:restart] 
    end
  else
    cmd = @new_resource.setup
    args = "-m silent -l yes -d \"#{@new_resource.install_dir}\""
    install_subdir = ::File.join(@new_resource.install_dir, node['portal']['install_subdir'])
    start_portal_path = ::File.join(install_subdir, "startportal.sh")
    run_as_user = @new_resource.run_as_user
   
    subdir = @new_resource.install_dir
    node['portal']['install_subdir'].split("/").each do |path|
      subdir = ::File.join(subdir, path)
      directory subdir do
        owner run_as_user
        group 'root'
        mode '0755'
        action :create
      end
    end
    
    execute "Install Portal for ArcGIS" do
      #command "\"#{cmd}\" #{args}"
      #user node['arcgis']['run_as_user']
      command "sudo -H -u #{node['arcgis']['run_as_user']} bash -c \"#{cmd} #{args}\""
      only_if {!::File.exists?(start_portal_path)}
    end

    configure_autostart(install_subdir)
  end
  
  new_resource.updated_by_last_action(true)
end

action :authorize do
  cmd = node['portal']['authorization_tool']

  if node['platform'] == 'windows'
    args = "/VER #{@new_resource.authorization_file_version} /LIF \"#{@new_resource.authorization_file}\" /S"
    
    execute "Authorize Portal for ArcGIS" do
      command "\"#{cmd}\" #{args}"
    end
  else 
    args = "-f \"#{@new_resource.authorization_file}\""
  
    execute "Authorize Portal for ArcGIS" do
      command "\"#{cmd}\" #{args}"
      user node['arcgis']['run_as_user']
    end
  end

  new_resource.updated_by_last_action(true)
end

action :create_site do
  portal_admin_client = ArcGIS::PortalAdminClient.new(@new_resource.portal_local_url, @new_resource.username, @new_resource.password)
  
  portal_admin_client.wait_until_available()

  if portal_admin_client.site_exist?
    Chef::Log.info("Portal site already exists.")
  else 
    Chef::Log.info("Creating portal site...")

    portal_admin_client.create_site(@new_resource.email, @new_resource.full_name, @new_resource.description, 
                             @new_resource.security_question, @new_resource.security_question_answer)

    sleep(120.0)

    change_content_dir(portal_admin_client, @new_resource.content_dir, node['arcgis']['run_as_user'])  

    new_resource.updated_by_last_action(true)
  end
end

action :register_server do
  portal_admin_client = ArcGIS::PortalAdminClient.new(@new_resource.portal_url, @new_resource.username, @new_resource.password)

  portal_admin_client.wait_until_available()

  servers = portal_admin_client.get_servers()
  
  server = servers.detect { |s| s['url'] == @new_resource.server_url } 
 
  if server != nil
    Chef::Log.warn("Server #{@new_resource.server_url} is already registered with portal (#{server['id']}).")
  else
    server_admin_uri = URI.parse(@new_resource.server_url + "/admin")
    server_name = server_admin_uri.host + ":" + server_admin_uri.port.to_s
    
    json = portal_admin_client.register_server(server_name, @new_resource.server_url, @new_resource.server_url, @new_resource.is_hosted, "ArcGIS")
  
    node.set['server']['server_id'] = json['serverId']
    node.set['server']['secret_key'] = json['secretKey']

    new_resource.updated_by_last_action(true)
  end
end

action :stop do
  if node['platform'] == 'windows' 
    service "Portal for ArcGIS" do
      action :stop
    end
  else
    install_dir = node['portal']['install_dir']

    execute "Stop Portal" do
      command ::File.join(install_dir, "arcgis/portal/stopportal.sh")
      user node['arcgis']['run_as_user']
    end
  end
  
  new_resource.updated_by_last_action(true)
end

action :start do
  if node['platform'] == 'windows'
    service "Portal for ArcGIS" do
      action :start
    end
  else
    install_dir = node['portal']['install_dir']
       
    execute "Start Portal" do
      command ::File.join(install_dir, "arcgis/portal/startportal.sh")
      user node['arcgis']['run_as_user']
    end
  end
  
  new_resource.updated_by_last_action(true)
end

private

def configure_autostart(portalhome)
  Chef::Log.info("Configure Portal for ArcGIS to be started with the operating system.")

  arcgisportal_path = "/etc/init.d/arcgisportal"

  if node["platform_family"] == "rhel"
    arcgisportal_path = "/etc/rc.d/init.d/arcgisportal" 
  end
  
  template arcgisportal_path do 
    source "arcgisportal.erb"
    variables ({:portalhome => portalhome})
    owner "root"
    group "root"
    mode 0755
    only_if {!::File.exists?(arcgisportal_path)}
  end
  
  service "arcgisportal" do
    supports :status => true, :restart => true, :reload => true
    action [:enable, :restart]
  end
end

def change_content_dir(portal_admin_client, content_dir, arcgis_user)
  if content_dir.nil? || content_dir.empty? 
    return
  end

  old_content_dir = portal_admin_client.get_content_dir()

  if content_dir == old_content_dir
    return
  end

  if ::File.directory? old_content_dir
    FileUtils.cp_r old_content_dir, ::File.expand_path("..", content_dir)
  
    if node['platform'] == 'windows'
      `icacls #{content_dir} /grant #{arcgis_user}:(OI)(CI)F`
    else
      FileUtils.chown_R arcgis_user, "root", content_dir
    end

    portal_admin_client.set_content_dir(content_dir)    
    
    sleep(120.0)
  else
    Chef::Log.warn("Failed to change portal content directory. Original content directory #{old_content_dir} is not available.")
  end
end
