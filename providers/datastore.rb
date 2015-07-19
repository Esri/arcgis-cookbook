#
# Cookbook Name:: arcgis
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

action :install do
  if node['platform'] == 'windows'
    install_dir = @new_resource.install_dir
    cmd = @new_resource.setup
    args = "/qb INSTALLDIR=\"#{install_dir}\""
    hostidentifier_properties_path = ::File.join(install_dir, "framework/etc/hostidentifier.properties")
    
    execute "Setup ArcGIS DataStore" do
      command "\"#{cmd}\" #{args}"
      only_if {!::File.exist?(install_dir)}
    end

    service "ArcGIS Data Store" do
      action [:enable, :start] 
    end
  else
    install_subdir = ::File.join(@new_resource.install_dir, node['data_store']['install_subdir']) 
    cmd = @new_resource.setup
    args = "-m silent -l yes -d \"#{@new_resource.install_dir}\""
    hostidentifier_properties_path = ::File.join(install_subdir, "framework/etc/hostidentifier.properties")
    run_as_user = @new_resource.run_as_user
    
    subdir = @new_resource.install_dir
    node['data_store']['install_subdir'].split("/").each do |path|
      subdir = ::File.join(subdir, path)
      directory subdir do
        owner run_as_user
        group 'root'
        mode '0755'
        action :create
      end
    end

    execute "Setup ArcGIS DataStore" do
      #command "\"#{cmd}\" #{args}"
      #user node['arcgis']['run_as_user']
      command "sudo -H -u #{node['arcgis']['run_as_user']} bash -c \"#{cmd} #{args}\""
      only_if {!::File.exist?(::File.join(install_subdir, "startdatastore.sh"))}
    end
    
    configure_autostart(install_subdir)
  end
  
  ruby_block "Set 'preferredidentifier' in hostidentifier.properties" do
     block do
       text = ::File.read(hostidentifier_properties_path)
       text.gsub!(/#\s*preferredidentifier\s*=\s*ip/, "preferredidentifier=#{node['data_store']['preferredidentifier']}")
       ::File.open(hostidentifier_properties_path, 'w') { |f| f.write(text) }
     end
     only_if {node['data_store']['preferredidentifier'] != nil}
     action :run
  end

  new_resource.updated_by_last_action(true)
end

action :configure do
  server_admin_url = "#{@new_resource.server_url}/admin"

  ruby_block "Wait for Server" do
    block do
      Utils.wait_until_url_available(server_admin_url)
    end
    action :run
  end
  
  if node['platform'] == 'windows' 
    cmd = ::File.join(@new_resource.install_dir, "tools\\configuredatastore")
    args = "\"#{server_admin_url}\" \"#{@new_resource.username}\" \"#{@new_resource.password}\" \"#{@new_resource.data_dir}\""
    env = {'AGSDATASTORE' => @new_resource.install_dir}
    install_dir = @new_resource.install_dir
    data_dir = @new_resource.data_dir
    run_as_user = @new_resource.run_as_user
    run_as_password = @new_resource.run_as_password

    execute "Configure ArcGIS DataStore" do
      command "\"#{cmd}\" #{args}"
      environment env
    end

    if run_as_user.include?("\\")
      service_logon_user = run_as_user
    else
      service_logon_user = ".\\#{run_as_user}"
    end

    ruby_block "Change 'ArcGIS Data Store' service logon account" do
      block do
        cmd = Mixlib::ShellOut.new("icacls.exe \"#{install_dir}\" /grant #{run_as_user}:(OI)(CI)F")
        cmd.run_command
        cmd.error!
        cmd = Mixlib::ShellOut.new("icacls.exe \"#{data_dir}\" /grant #{run_as_user}:(OI)(CI)F")
        cmd.run_command
        cmd.error!
        cmd = Mixlib::ShellOut.new("sc.exe config \"ArcGIS Data Store\" obj= \"#{service_logon_user}\" password= \"#{run_as_password}\"")
        cmd.run_command
        cmd.error!
      end
      #sensitive true
      action :run
    end

    service "ArcGIS Data Store" do
      action [:restart] 
    end
  else
    install_subdir = ::File.join(@new_resource.install_dir, node['data_store']['install_subdir'])
    cmd = ::File.join(install_subdir, "tools/configuredatastore.sh")
    args = "\"#{server_admin_url}\" \"#{@new_resource.username}\" \"#{@new_resource.password}\" \"#{@new_resource.data_dir}\""
    run_as_user = @new_resource.run_as_user
    
    execute "Configure ArcGIS DataStore" do
      command "\"#{cmd}\" #{args}"
      user run_as_user
    end
  end

  change_backup_location(@new_resource.install_dir, @new_resource.backup_dir, @new_resource.run_as_user, @new_resource.run_as_password)
  
  new_resource.updated_by_last_action(true)
end

private

def configure_autostart(datastorehome)
  Chef::Log.info("Configure ArcGIS Data Store to be started with the operating system.")
  
  arcgisdatastore_path = "/etc/init.d/arcgisdatastore"
  
  if node["platform_family"] == "rhel"
    arcgisdatastore_path = "/etc/rc.d/init.d/arcgisdatastore" 
  end
  
  template arcgisdatastore_path do 
    source "arcgisdatastore.erb"
    variables ({:datastorehome => datastorehome})
    owner "root"
    group "root"
    mode 0755
    only_if {!::File.exists?(arcgisdatastore_path)}
  end

  service "arcgisdatastore" do
    supports :status => true, :restart => true, :reload => true
    action [:enable, :start]
  end
end

def change_backup_location(install_dir, backup_dir, run_as_user, run_as_password)
  if node['platform'] == 'windows' 
    cmd = ::File.join(install_dir, "tools\\changebackuplocation")
    is_shared_folder = backup_dir.start_with?("\\\\") ? "true" : "false"
    args = "\"#{backup_dir}\" --is-shared-folder #{is_shared_folder} --keep-old-backups true --prompt no"
    env = {'AGSDATASTORE' => install_dir}

    execute "Change ArcGIS DataStore Backup Location" do
      command "\"#{cmd}\" #{args}"
      environment env
    end
  else
    install_subdir = ::File.join(install_dir, node['data_store']['install_subdir'])
    cmd = ::File.join(install_subdir, "tools/changebackuplocation.sh")
    args = "\"#{backup_dir}\" --is-shared-folder true --keep-old-backups true --prompt no"
    
    execute "Change ArcGIS DataStore Backup Location" do
      command "\"#{cmd}\" #{args}"
      user run_as_user
    end
  end
end