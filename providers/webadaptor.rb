#
# Cookbook Name:: arcgis
# Provider:: webadaptor
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

require 'fileutils'
require "net/http"
require "uri"
require "json"

action :install do
  if node['platform'] == 'windows'
    cmd = @new_resource.setup
    args = "/qb VDIRNAME=#{@new_resource.instance_name}"
    web_app_path = "C:\\inetpub\\wwwroot\\" + @new_resource.instance_name

    execute "Run ArcGIS Web Adaptor Setup" do
      command "\"#{cmd}\" #{args}"
      only_if {!::File.exists?(web_app_path)}
    end
  else
    install_subdir = ::File.join(@new_resource.install_dir, node['web_adaptor']['install_subdir'])
    src_path = ::File.join(install_subdir, "java/arcgis.war")
    dst_path = ::File.join(node['tomcat']['webapp_dir'], @new_resource.instance_name + ".war")
    cmd = @new_resource.setup
    args = "-m silent -l yes -d \"#{@new_resource.install_dir}\""
    service_name = node['tomcat']['base_instance']

    subdir = @new_resource.install_dir
    node['web_adaptor']['install_subdir'].split("/").each do |path|
      subdir = ::File.join(subdir, path)
      directory subdir do
        owner node['arcgis']['run_as_user']
        group 'root'
        mode '0755'
        action :create
      end
    end
    
    execute "Run ArcGIS Web Adaptor Setup" do
      command "\"#{cmd}\" #{args}"
      user node['arcgis']['run_as_user']
      only_if {!::File.exists?(src_path)}
    end

    remote_file dst_path do
      source "file://" + src_path
      mode '0755'
      only_if {!::File.exists?(dst_path)}
      notifies :restart, "service[#{service_name}]", :immediately
    end
    
    service service_name do
      action :nothing
    end
  end
  
  new_resource.updated_by_last_action(true)
end

action :configure_with_server do
  wa_url = @new_resource.server_url + "/webadaptor"
  server_url = @new_resource.server_local_url

  ruby_block "Wait for Server and WA" do
    block do
      Utils.wait_until_url_available(wa_url)
      Utils.wait_until_url_available(server_url)
    end
    action :run
  end

  if node['platform'] == 'windows'
    cmd = "#{ENV['CommonProgramFiles(x86)']}\\ArcGIS\\WebAdaptor\\IIS\\Tools\\ConfigureWebAdaptor.exe";
    args = "/m server /w \"#{wa_url}\" /g \"#{server_url}\" /u \"#{@new_resource.username}\" /p \"#{@new_resource.password}\" /a true"

    execute "Configure Web Adaptor with Server" do
      command "\"#{cmd}\" #{args}"
    end
  else
    cmd = "java";

    wareg_jar_path = ::File.join(@new_resource.install_dir, node['web_adaptor']['install_subdir'], "java/tools/arcgis-wareg.jar")
    args = "-jar \"#{wareg_jar_path}\" -m server -w '#{wa_url}' -g '#{server_url}' -u '#{@new_resource.username}' -p '#{@new_resource.password}' -a true"

    execute "Configure Web Adaptor with Server" do
      command "\"#{cmd}\" #{args}"
    end
  end
  
  new_resource.updated_by_last_action(true)
end

action :configure_with_portal do
  wa_url = @new_resource.portal_url + "/webadaptor"
  private_portal_url = @new_resource.portal_local_url

  ruby_block "Wait until Portal and Web Adaptor are available" do
    block do
      Utils.wait_until_url_available(private_portal_url)
      Utils.wait_until_url_available(wa_url)
    end
    action :run
  end

  if node['platform'] == 'windows'
    cmd = "#{ENV['CommonProgramFiles(x86)']}\\ArcGIS\\WebAdaptor\\IIS\\Tools\\ConfigureWebAdaptor.exe";
    args = "/m portal /w \"#{wa_url}\" /g \"#{private_portal_url}\" /u \"#{@new_resource.username}\" /p \"#{@new_resource.password}\""
    gw_config_path = ::File.join(node['portal']['install_dir'], "webapps\\arcgis#sharing\\WEB-INF\\classes\\resources\\gw-config.properties")

    execute "Configure Web Adaptor with Portal" do
      command "\"#{cmd}\" #{args}"
    end
  else
    cmd = "java";

    wareg_jar_path = ::File.join(@new_resource.install_dir, node['web_adaptor']['install_subdir'], "java/tools/arcgis-wareg.jar")
    args = "-jar \"#{wareg_jar_path}\" -m portal -w '#{wa_url}' -g '#{private_portal_url}' -u '#{@new_resource.username}' -p '#{@new_resource.password}'"
    gw_config_path = ::File.join(node['portal']['install_dir'], "arcgis/portal/webapps/arcgis#sharing/WEB-INF/classes/resources/gw-config.properties")
      
    execute "Configure Web Adaptor with Portal" do
      command "\"#{cmd}\" #{args}"
    end
  end

  portal_url = @new_resource.portal_url
  username = @new_resource.username
  password = @new_resource.password
  domain = URI.parse(portal_url).host
  
  ruby_block "Update portal system properties" do
    block do
      portal_admin_client = ArcGIS::PortalAdminClient.new(portal_url, username, password)
      portal_admin_client.wait_until_available()
      portal_admin_client.update_system_properties(domain)
    end
    action :run
  end
  
#  arcgis_portal "Stop Portal" do
#    action :stop
#  end
#  
#  ruby_block "Replace ports in gw-config.properties" do
#    block do
#      text = ::File.read(gw_config_path)
#      text.gsub!(/webserver.http.port\s*=\s*7080/, "webserver.http.port=80")
#      text.gsub!(/webserver.https.port\s*=\s*7443/, "webserver.https.port=443")
#      text.concat("\nportalLocalhostName=" + domain)
#      ::File.open(gw_config_path, 'w') { |f| f.write(text) }
#    end
#    action :run
#  end
#  
#  arcgis_portal "Start Portal" do
#    action :start
#  end
  
  ruby_block "Wait until portal is available" do
    block do
      Utils.wait_until_url_available(private_portal_url + "/arcgis/home")
    end
    action :run
  end
  
  new_resource.updated_by_last_action(true)
end